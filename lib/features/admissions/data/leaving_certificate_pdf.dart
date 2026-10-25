import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/pdf_school_header.dart';
import '../../../core/utils/pdf_urdu_text.dart';
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

  /// A4 width less the page margin, the two borders and the inner padding.
  static const _sentenceWidth = 595.28 - 2 * 28 - 2 * 5 - 2 * 32 - 2 * 3;

  Future<void> _loadFonts() async {
    Future<pw.Font> load(String path) async => pw.Font.ttf(await rootBundle.load(path));
    _regular ??= await load('assets/fonts/Inter-400.ttf');
    _bold ??= await load('assets/fonts/Inter-700.ttf');
    _urdu ??= await load('assets/fonts/NotoNaskhArabic-400.ttf');
  }

  @override
  Future<Uint8List> build(LeavingCertificate c) async {
    await _loadFonts();
    final logo = await loadPdfLogo(c.logoPath);
    return PdfUrduText.run((urdu) => _render(urdu, c, logo));
  }

  Future<Uint8List> _render(PdfUrduText urdu, LeavingCertificate c, pw.ImageProvider? logo) {
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
            child: _content(urdu, c, logo),
          ),
        ),
      ),
    );
    return doc.save();
  }

  pw.Widget _content(PdfUrduText urdu, LeavingCertificate c, pw.ImageProvider? logo) {
    final relation = c.gender == 'female' ? 'D/O' : 'S/O';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pdfCenteredSchoolHeader(
          urdu: urdu,
          name: c.schoolName,
          address: c.schoolAddress,
          phone: c.schoolPhone,
          logo: logo,
          nameSize: 26,
          nameColor: _accent,
          detailColor: _muted,
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
        urdu.text(
          'This is to certify that ${_value(c.studentName)} $relation ${_value(c.fatherName)} '
          'was a student of this school. The details are given below.',
          style: const pw.TextStyle(fontSize: 12, lineSpacing: 4, color: _ink),
          maxWidth: _sentenceWidth,
        ),
        pw.SizedBox(height: 16),
        _row(urdu, 'Admission No', c.admissionNo),
        _row(urdu, 'Name of student', c.studentName),
        _row(urdu, 'Father name', c.fatherName),
        _row(urdu, 'Date of birth (in figures)', _date(c.dob)),
        _row(urdu, 'Date of birth (in words)', c.dob == null ? '' : NumberWords.dateInWords(c.dob!)),
        _row(urdu, 'Date of admission', _date(c.admissionDate)),
        _row(urdu, 'Attended school from', _date(c.attendedFrom)),
        _row(urdu, 'Attended school to', _date(c.attendedTo)),
        _row(urdu, 'Class', c.className),
        _row(urdu, 'Last exam passed', c.exam),
        _row(urdu, 'Promoted to class', c.promotedClass),
        _row(urdu, 'All dues cleared', c.duesCleared ? 'Yes' : 'No'),
        _row(urdu, 'Attendance', c.attendance),
        _row(urdu, 'Discipline / conduct', c.discipline),
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

  pw.Widget _row(PdfUrduText urdu, String label, String value) {
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
              child: urdu.text(
                _value(value),
                fill: true,
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
