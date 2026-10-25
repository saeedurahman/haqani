import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/pdf_school_header.dart';
import '../../../core/utils/pdf_urdu_text.dart';
import '../domain/result_calculator.dart';
import '../domain/result_card.dart';
import '../domain/result_card_pdf_service.dart';

/// Result card on A4, one page per student.
class ResultCardPdf implements ResultCardPdfService {
  pw.Font? _regular;
  pw.Font? _bold;
  pw.Font? _urdu;

  static const _ink = PdfColor.fromInt(0xFF1B1B3A);
  static const _accent = PdfColor.fromInt(0xFF3730A3);
  static const _muted = PdfColor.fromInt(0xFF6B7194);
  static const _soft = PdfColor.fromInt(0xFFF1F2FA);
  static const _red = PdfColor.fromInt(0xFFE11D48);
  static const _green = PdfColor.fromInt(0xFF16A34A);

  Future<void> _loadFonts() async {
    Future<pw.Font> load(String path) async => pw.Font.ttf(await rootBundle.load(path));
    _regular ??= await load('assets/fonts/Inter-400.ttf');
    _bold ??= await load('assets/fonts/Inter-700.ttf');
    _urdu ??= await load('assets/fonts/NotoNaskhArabic-400.ttf');
  }

  @override
  Future<Uint8List> build(List<ResultCard> cards) async {
    await _loadFonts();
    final logo = await loadPdfLogo(cards.first.school.logoPath);
    return PdfUrduText.run((urdu) => _render(urdu, cards, logo));
  }

  Future<Uint8List> _render(PdfUrduText urdu, List<ResultCard> cards, pw.ImageProvider? logo) {
    final doc = pw.Document(
      title: cards.length == 1
          ? 'Result Card - ${cards.first.result.student.name}'
          : 'Result Cards - ${cards.first.exam.name}',
      theme: pw.ThemeData.withFont(base: _regular!, bold: _bold!, fontFallback: [_urdu!]),
    );
    for (final card in cards) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (_) => pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _accent, width: 3)),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(color: _accent, width: 0.8)),
              padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 26),
              child: _content(urdu, card, logo),
            ),
          ),
        ),
      );
    }
    return doc.save();
  }

  pw.Widget _content(PdfUrduText urdu, ResultCard c, pw.ImageProvider? logo) {
    final r = c.result;
    final date = c.exam.date;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pdfCenteredSchoolHeader(
          urdu: urdu,
          name: c.school.name,
          address: c.school.address,
          phone: c.school.phone,
          logo: logo,
          nameSize: 25,
          nameColor: _accent,
          detailColor: _muted,
        ),
        pw.SizedBox(height: 14),
        pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 7),
            decoration: pw.BoxDecoration(color: _accent, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(
              'RESULT CARD',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: urdu.text(
            date == null ? c.exam.name : '${c.exam.name}  -  ${AppDateUtils.toDisplay(date)}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink),
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _info(urdu, 'Student name', r.student.name, bold: true),
                    _info(urdu, 'Father name', r.student.fatherName),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _info(urdu, 'Admission No', r.student.admissionNo),
                    _info(urdu, 'Class / Section', c.classLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _marksTable(urdu, c),
        pw.SizedBox(height: 16),
        _summary(c),
        pw.Spacer(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _signature('Class Teacher'),
            _signature('Parent'),
            _signature('Principal'),
          ],
        ),
      ],
    );
  }

  pw.Widget _marksTable(PdfUrduText urdu, ResultCard c) {
    pw.Widget cell(String text, {bool header = false, bool bold = false, pw.Alignment? align}) {
      return pw.Container(
        alignment: align ?? pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: urdu.text(
          text,
          fill: true,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: header || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: header ? PdfColors.white : _ink,
          ),
        ),
      );
    }

    final right = pw.Alignment.centerRight;
    final center = pw.Alignment.center;
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _accent),
          children: [
            cell('Subject', header: true),
            cell('Total marks', header: true, align: right),
            cell('Obtained', header: true, align: right),
            cell('Grade', header: true, align: center),
          ],
        ),
        for (final l in c.lines)
          pw.TableRow(children: [
            cell(l.name),
            cell('${l.totalMarks}', align: right),
            cell(l.obtained == null ? '-' : '${l.obtained}', align: right),
            cell(l.grade, align: center),
          ]),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _soft),
          children: [
            cell('Total', bold: true),
            cell('${c.result.maxMarks}', bold: true, align: right),
            cell('${c.result.obtained}', bold: true, align: right),
            cell(c.result.grade, bold: true, align: center),
          ],
        ),
      ],
    );
  }

  pw.Widget _summary(ResultCard c) {
    final r = c.result;
    final resultColor = switch (r.status) {
      ResultStatus.pass => _green,
      ResultStatus.fail => _red,
      _ => _muted,
    };
    final position = r.position == null ? '-' : '${_ordinal(r.position!)} of ${c.rankedStudents}';
    return pw.Row(
      children: [
        _box('Percentage', '${r.percent.toStringAsFixed(1)}%'),
        pw.SizedBox(width: 10),
        _box('Grade', r.grade),
        pw.SizedBox(width: 10),
        _box('Position', position),
        pw.SizedBox(width: 10),
        _box('Result', r.status.label.toUpperCase(), color: resultColor),
      ],
    );
  }

  pw.Widget _box(String label, String value, {PdfColor color = _ink}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _info(PdfUrduText urdu, String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          urdu.text(
            value.trim().isEmpty ? '-' : value,
            style: pw.TextStyle(
              fontSize: 12,
              color: _ink,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _signature(String label) {
    return pw.Column(
      children: [
        pw.Container(width: 120, height: 0.8, color: _ink),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: _muted)),
      ],
    );
  }

  /// 1 -> 1st, 2 -> 2nd, 11 -> 11th, 23 -> 23rd.
  static String _ordinal(int n) {
    final lastTwo = n % 100;
    if (lastTwo >= 11 && lastTwo <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}
