import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/number_words.dart';
import '../domain/certificate_pdf_service.dart';
import '../domain/leaving_certificate.dart';

/// Draws the School Leaving Certificate on one A4 page.
class LeavingCertificatePdf implements CertificatePdfService {
  pw.Font? _regular;
  pw.Font? _bold;
  pw.Font? _urdu;

  static const _ink = PdfColor.fromInt(0xFF1B1B3A);
  static const _accent = PdfColor.fromInt(0xFF3730A3);
  static const _muted = PdfColor.fromInt(0xFF6B7194);

  Future<void> _loadFonts() async {
    Future<pw.Font> load(String path) async => pw.Font.ttf(await rootBundle.load(path));
    _regular ??= await load('assets/fonts/Inter-400.ttf');
    _bold ??= await load('assets/fonts/Inter-700.ttf');
    _urdu ??= await load('assets/fonts/NotoNaskhArabic-400.ttf');
  }

  @override
  Future<Uint8List> build(LeavingCertificate c) async {
    await _loadFonts();
    final doc = pw.Document(
      title: 'School Leaving Certificate - ${c.studentName}',
      theme: pw.ThemeData.withFont(
        base: _regular!,
        bold: _bold!,
        fontFallback: [_urdu!],
      ),
    );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _accent, width: 3)),
          padding: const pw.EdgeInsets.all(5),
          child: pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _accent, width: 0.8)),
            padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: _content(c),
          ),
        ),
      ),
    );
    return doc.save();
  }

  pw.Widget _content(LeavingCertificate c) {
    final relation = c.gender == 'female' ? 'D/O' : 'S/O';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.Text(
            c.schoolName,
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _accent),
          ),
        ),
        if (c.schoolAddress.isNotEmpty)
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(c.schoolAddress, style: const pw.TextStyle(fontSize: 11, color: _muted)),
            ),
          ),
        pw.SizedBox(height: 18),
        pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _accent,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'SCHOOL LEAVING CERTIFICATE',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 22),
        pw.Text(
          'This is to certify that ${_value(c.studentName)} $relation ${_value(c.fatherName)} '
          'was a student of this school. The details are given below.',
          style: const pw.TextStyle(fontSize: 12, lineSpacing: 4, color: _ink),
        ),
        pw.SizedBox(height: 16),
        _row('Admission No', c.admissionNo),
        _row('Name of student', c.studentName),
        _row('Father name', c.fatherName),
        _row('Date of birth (in figures)', _date(c.dob)),
        _row('Date of birth (in words)', c.dob == null ? '' : NumberWords.dateInWords(c.dob!)),
        _row('Date of admission', _date(c.admissionDate)),
        _row('Attended school from', _date(c.attendedFrom)),
        _row('Attended school to', _date(c.attendedTo)),
        _row('Class', c.className),
        _row('Last exam passed', c.exam),
        _row('Promoted to class', c.promotedClass),
        _row('All dues cleared', c.duesCleared ? 'Yes' : 'No'),
        _row('Attendance', c.attendance),
        _row('Discipline / conduct', c.discipline),
        pw.Spacer(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _signature('Class Teacher'),
            pw.Text(
              'Date of issue: ${_date(c.issueDate)}',
              style: const pw.TextStyle(fontSize: 11, color: _ink),
            ),
            _signature('Principal'),
          ],
        ),
      ],
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 170,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 11.5, fontWeight: pw.FontWeight.bold, color: _muted),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.6)),
              ),
              child: pw.Text(
                _value(value),
                style: const pw.TextStyle(fontSize: 12.5, color: _ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _signature(String label) {
    return pw.Column(
      children: [
        pw.Container(width: 130, height: 0.8, color: _ink),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }

  String _value(String v) => v.trim().isEmpty ? '-' : v.trim();

  String _date(DateTime? d) => d == null ? '' : AppDateUtils.toDisplay(d);
}
