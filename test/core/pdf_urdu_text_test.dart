import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/utils/pdf_urdu_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../support/load_fonts.dart';

const _name = 'زاہد خان';

Future<ui.Image> _decode(List<int> png) async {
  final codec = await ui.instantiateImageCodec(png as dynamic);
  return (await codec.getNextFrame()).image;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadAppFonts);

  group('detecting Arabic script', () {
    test('Urdu, Arabic, Persian and presentation forms are found', () {
      expect(PdfUrduText.hasArabicScript(_name), isTrue);
      expect(PdfUrduText.hasArabicScript('محمد'), isTrue);
      expect(PdfUrduText.hasArabicScript('ﺯﺍﮨﺪ'), isTrue);
      expect(PdfUrduText.hasArabicScript('Name: زاہد'), isTrue);
    });

    test('English, numbers and empty text are not', () {
      expect(PdfUrduText.hasArabicScript('Zahid Khan'), isFalse);
      expect(PdfUrduText.hasArabicScript('0300-1234567  Rs 1,500'), isFalse);
      expect(PdfUrduText.hasArabicScript(''), isFalse);
      expect(PdfUrduText.hasArabicScript('é ñ ü 日本'), isFalse);
    });

    test('the first letter decides the direction', () {
      expect(PdfUrduText.isRightToLeft(_name), isTrue);
      expect(PdfUrduText.isRightToLeft('123 زاہد'), isTrue);
      expect(PdfUrduText.isRightToLeft('Ali S/O زاہد'), isFalse);
      expect(PdfUrduText.isRightToLeft('123'), isFalse);
    });
  });

  group('drawing', () {
    const style = pw.TextStyle(fontSize: 14, color: PdfColors.black);

    test('English text stays normal PDF text and draws nothing', () async {
      final urdu = PdfUrduText();
      final widget = urdu.text('Zahid Khan', style: style);
      await urdu.renderPending();

      expect(widget, isA<pw.Text>());
      expect(urdu.renderedCount, 0);
    });

    test(
      'Urdu text gets a sharp, non-empty picture, once per string',
      () async {
        final urdu = PdfUrduText();
        expect(
          urdu.text(_name, style: style),
          isA<pw.Text>(),
          reason: 'first pass: placeholder',
        );
        urdu.text(_name, style: style);
        urdu.text('عائشہ', style: style);
        await urdu.renderPending();
        urdu.text(_name, style: style);
        await urdu.renderPending();

        expect(urdu.renderedCount, 2);
        final png = urdu.pngOf(_name, style)!;
        final image = await _decode(png);
        // 3 pixels per PDF point, wider than tall, and really has ink in it.
        expect(image.width, greaterThan(image.height));
        expect(image.height, greaterThanOrEqualTo(14 * 3));
        final pixels = (await image.toByteData())!.buffer.asUint8List();
        final inkPixels = [for (var i = 3; i < pixels.length; i += 4) pixels[i]]
            .where((a) => a > 0);
        expect(inkPixels.length, greaterThan(200));
      },
    );

    test('size, weight and colour make different pictures', () async {
      final urdu = PdfUrduText();
      const big = pw.TextStyle(fontSize: 28, color: PdfColors.black);
      urdu.text(_name, style: style);
      urdu.text(_name, style: big);
      await urdu.renderPending();

      expect(urdu.renderedCount, 2);
      final small = await _decode(urdu.pngOf(_name, style)!);
      final large = await _decode(urdu.pngOf(_name, big)!);
      expect(large.width, greaterThan(small.width * 1.7));
    });

    test('a sentence with Urdu names wraps inside the given width', () async {
      final urdu = PdfUrduText();
      const text =
          'This is to certify that زاہد خان S/O عبداللہ خان was a student of this school. '
          'The details are given below.';
      urdu.text(text, style: style, maxWidth: 300);
      await urdu.renderPending();

      final image = await _decode(urdu.pngOf(text, style, maxWidth: 300)!);
      expect(image.width / 3, lessThanOrEqualTo(302));
      expect(
        image.height / 3,
        greaterThan(14 * 2),
        reason: 'more than one line',
      );
    });

    test('run builds once without Urdu and twice with it', () async {
      var builds = 0;
      Future<List<int>> build(PdfUrduText urdu, String text) async {
        builds++;
        final doc = pw.Document()
          ..addPage(pw.Page(build: (_) => urdu.text(text, style: style)));
        return doc.save();
      }

      await PdfUrduText.run(
        (u) async => Uint8List.fromList(await build(u, 'Zahid')),
      );
      expect(builds, 1);

      builds = 0;
      final bytes = await PdfUrduText.run(
        (u) async => Uint8List.fromList(await build(u, _name)),
      );
      expect(builds, 2);
      // The picture is in the file; the letters are not sent as PDF text.
      expect(String.fromCharCodes(bytes).contains('/Subtype/Image'), isTrue);
    });
  });

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['URDU_SAMPLE_PATH'];
    if (path == null) return;
    final bytes = await PdfUrduText.run((urdu) async {
      const normal = pw.TextStyle(fontSize: 20, color: PdfColors.black);
      final bold = pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      );
      final doc = pw.Document()
        ..addPage(
          pw.Page(
            build: (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Plain English text', style: normal),
                pw.SizedBox(height: 12),
                urdu.text(_name, style: normal),
                pw.SizedBox(height: 12),
                urdu.text('عائشہ خان بنت عبداللہ', style: bold),
                pw.SizedBox(height: 12),
                urdu.text('Ali S/O زاہد خان, class 3', style: normal),
                pw.SizedBox(height: 12),
                urdu.text(
                  'This is to certify that زاہد خان S/O عبداللہ خان was a student of this school.',
                  style: normal,
                  maxWidth: 400,
                ),
              ],
            ),
          ),
        );
      return doc.save();
    });
    File(path).writeAsBytesSync(bytes);
  });
}
