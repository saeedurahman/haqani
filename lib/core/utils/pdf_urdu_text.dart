import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Urdu and other Arabic-script text for PDFs.
///
/// The `pdf` package does not join or reorder Arabic letters, so such text
/// comes out disconnected and backwards. This helper draws it with Flutter's
/// own text engine (correct joining, right-to-left, Noto Naskh Arabic) into a
/// sharp picture and puts that picture in the PDF. English and numbers stay
/// normal PDF text.
///
/// A PDF is built in two passes, see [run]: the first pass finds which strings
/// need a picture, then they are drawn once each and the second pass uses them.
class PdfUrduText {
  PdfUrduText({this.scale = 3});

  /// Picture pixels per PDF point. 3 keeps print sharp.
  final double scale;

  /// Naskh letters look smaller than Latin ones of the same size, so Urdu is
  /// drawn a little bigger to match the English text beside it.
  static const _sizeBoost = 1.2;

  static const _urduFont = 'NotoNaskhArabic';
  static const _latinFont = 'Inter';

  final Map<String, _Picture> _done = {};
  final Map<String, _Request> _pending = {};

  /// True if the text has at least one Arabic-script letter (Urdu, Arabic,
  /// Persian, Pashto...).
  static bool hasArabicScript(String text) => text.runes.any(_isArabic);

  static bool _isArabic(int c) =>
      (c >= 0x0600 && c <= 0x06FF) ||
      (c >= 0x0750 && c <= 0x077F) ||
      (c >= 0x08A0 && c <= 0x08FF) ||
      (c >= 0xFB50 && c <= 0xFDFF) ||
      (c >= 0xFE70 && c <= 0xFEFF);

  /// The first letter decides the direction: "زاہد S/O خان" is right-to-left,
  /// "Ali S/O زاہد" is left-to-right.
  static bool isRightToLeft(String text) {
    for (final c in text.runes) {
      if (_isArabic(c)) return true;
      if ((c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A)) return false;
    }
    return false;
  }

  /// Text with the given look. Plain [pw.Text] when there is no Arabic script.
  ///
  /// The picture is as wide as the text, like a normal [pw.Text]. With
  /// [fill] it takes the whole width it is given (a table cell, a form line)
  /// and sits on the side set by [textAlign]: right for right-to-left text and
  /// left for left-to-right text unless you pass one. Give [maxWidth] (in
  /// points) for a sentence that must wrap; otherwise the text is one line, and
  /// is scaled down to fit when the space is narrower than the line.
  pw.Widget text(
    String text, {
    required pw.TextStyle style,
    pw.TextAlign? textAlign,
    double? maxWidth,
    bool fill = false,
  }) {
    if (!hasArabicScript(text)) {
      return pw.Text(text, style: style, textAlign: textAlign);
    }
    final request = _Request(text, style, maxWidth);
    final picture = _done[request.key];
    if (picture == null) {
      // First pass: remember it. The real picture comes in the second pass.
      // Only a stand-in is laid out now, so no letters reach the PDF engine.
      _pending[request.key] = request;
      return pw.Text('-', style: style);
    }
    final image = pw.FittedBox(
      fit: pw.BoxFit.scaleDown,
      child: pw.Image(
        picture.image,
        width: picture.width,
        height: picture.height,
      ),
    );
    if (!fill) return image;
    final align =
        textAlign ??
        (isRightToLeft(text) ? pw.TextAlign.right : pw.TextAlign.left);
    return pw.Align(
      alignment: switch (align) {
        pw.TextAlign.right => pw.Alignment.centerRight,
        pw.TextAlign.center => pw.Alignment.center,
        _ => pw.Alignment.centerLeft,
      },
      child: image,
    );
  }

  /// Number of different strings that were drawn so far.
  int get renderedCount => _done.length;

  /// The PNG drawn for a string, or null if it was not drawn yet.
  @visibleForTesting
  Uint8List? pngOf(String text, pw.TextStyle style, {double? maxWidth}) {
    return _done[_Request(text, style, maxWidth).key]?.image.bytes;
  }

  /// Draws every string asked for in the last pass.
  Future<void> renderPending() async {
    final requests = _pending.values.toList();
    _pending.clear();
    for (final r in requests) {
      _done[r.key] = await _draw(r);
    }
  }

  /// Builds a PDF with Arabic-script text drawn correctly. [build] must make a
  /// new document each time it is called. A PDF without such text is built once.
  static Future<Uint8List> run(
    Future<Uint8List> Function(PdfUrduText urdu) build,
  ) async {
    final urdu = PdfUrduText();
    final first = await build(urdu);
    if (urdu._pending.isEmpty) return first;
    await urdu.renderPending();
    return build(urdu);
  }

  Future<_Picture> _draw(_Request r) async {
    final rtl = isRightToLeft(r.text);
    ui.Paragraph layout(double width) {
      final builder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textDirection: rtl
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                textAlign: ui.TextAlign.start,
              ),
            )
            ..pushStyle(
              ui.TextStyle(
                color: ui.Color(r.color.toInt()),
                fontSize: r.fontSize * _sizeBoost,
                fontWeight: r.bold ? ui.FontWeight.w700 : ui.FontWeight.w400,
                fontFamily: _latinFont,
                fontFamilyFallback: const [_urduFont],
                height: 1.15,
              ),
            )
            ..addText(r.text);
      return builder.build()..layout(ui.ParagraphConstraints(width: width));
    }

    // Measure first, then lay out again as wide as the text needs, so the
    // picture has no empty space and alignment stays exact.
    final measured = layout(r.maxWidth ?? 10000);
    final width = math.max(1.0, measured.longestLine.ceilToDouble() + 1);
    final paragraph = layout(width);
    final height = math.max(1.0, paragraph.height.ceilToDouble());

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(scale);
    canvas.drawParagraph(paragraph, ui.Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * scale).ceil(),
      (height * scale).ceil(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return _Picture(pw.MemoryImage(data!.buffer.asUint8List()), width, height);
  }
}

class _Request {
  _Request(this.text, pw.TextStyle style, this.maxWidth)
    : fontSize = style.fontSize ?? 12,
      bold = style.fontWeight == pw.FontWeight.bold,
      color = style.color ?? PdfColors.black;

  final String text;
  final double fontSize;
  final bool bold;
  final PdfColor color;
  final double? maxWidth;

  String get key => '$fontSize|$bold|${color.toInt()}|$maxWidth|$text';
}

class _Picture {
  const _Picture(this.image, this.width, this.height);

  final pw.MemoryImage image;
  final double width;
  final double height;
}
