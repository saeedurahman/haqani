import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/pdf_school_header.dart';
import '../domain/fee_models.dart';
import '../domain/receipt_pdf_service.dart';

/// Fee receipt on A5. One receipt can list several brothers and sisters.
class FeeReceiptPdf implements ReceiptPdfService {
  pw.Font? _regular;
  pw.Font? _bold;
  pw.Font? _urdu;

  static const _ink = PdfColor.fromInt(0xFF1B1B3A);
  static const _accent = PdfColor.fromInt(0xFF3730A3);
  static const _muted = PdfColor.fromInt(0xFF6B7194);
  static const _soft = PdfColor.fromInt(0xFFF1F2FA);

  Future<void> _loadFonts() async {
    Future<pw.Font> load(String path) async => pw.Font.ttf(await rootBundle.load(path));
    _regular ??= await load('assets/fonts/Inter-400.ttf');
    _bold ??= await load('assets/fonts/Inter-700.ttf');
    _urdu ??= await load('assets/fonts/NotoNaskhArabic-400.ttf');
  }

  @override
  Future<Uint8List> build(FeeReceipt receipt) async {
    await _loadFonts();
    final logo = await loadPdfLogo(receipt.logoPath);
    final doc = pw.Document(
      title: 'Fee Receipt ${receipt.receiptNo}',
      theme: pw.ThemeData.withFont(base: _regular!, bold: _bold!, fontFallback: [_urdu!]),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => _header(receipt, logo),
        footer: (_) => _footer(),
        build: (_) => [
          for (final line in receipt.lines) _student(line),
          if (receipt.lines.length > 1) _grandTotal(receipt),
          if (receipt.note.isNotEmpty) _note(receipt.note),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _header(FeeReceipt r, pw.ImageProvider? logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pdfCenteredSchoolHeader(
          name: r.schoolName,
          address: r.schoolAddress,
          phone: r.schoolPhone,
          logo: logo,
          nameSize: 19,
          nameColor: _accent,
          detailColor: _muted,
          logoSize: 38,
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: pw.BoxDecoration(color: _accent, borderRadius: pw.BorderRadius.circular(5)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'FEE RECEIPT',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 1,
                ),
              ),
              pw.Text(
                'Receipt No: ${r.receiptNo}     Date: ${AppDateUtils.toDisplay(r.date)}',
                style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.white),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _footer() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Thank you', style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.Column(
            children: [
              pw.Container(width: 110, height: 0.7, color: _ink),
              pw.SizedBox(height: 3),
              pw.Text('Signature / Stamp', style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
            ],
          ),
        ],
      ),
    );
  }

  /// A Row, so a student block moves to the next page as one piece.
  pw.Widget _student(ReceiptLine line) {
    final v = line.voucher;
    final month = DateFormat('MMMM yyyy').format(DateTime.parse('${v.forMonth}-01'));
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _info('Student', v.student.name, bold: true),
                _info('Registration No',
                    v.student.registrationNo.isEmpty ? v.student.admissionNo : v.student.registrationNo),
                _info('Class / Section', v.student.classLabel),
                _info('Fee for', month),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                _amount('Monthly fee', v.monthlyFee),
                _amount('Annual fee', v.annualFee),
                _amount('Admission fee', v.admissionFee),
                _amount('Misc fee', v.miscFee),
                if (v.previousDues > 0) _amount('Previous dues', v.previousDues),
                if (v.discount > 0) _amount('Discount', -v.discount),
                pw.Divider(color: PdfColors.grey400, thickness: 0.6, height: 8),
                _amount('Total', v.total, bold: true),
                if (line.receivedNow != null)
                  _amount('Received now', line.receivedNow!, bold: true, accent: true),
                _amount('Paid so far', v.paidAmount),
                _amount('Balance', v.balance, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _note(String note) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Text('Note: $note', style: const pw.TextStyle(fontSize: 9.5, color: _ink)),
    );
  }

  pw.Widget _grandTotal(FeeReceipt r) {
    final now = r.lines.fold<int>(0, (s, l) => s + (l.receivedNow ?? 0));
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        children: [
          if (now > 0) _amount('Total received now', now, bold: true, accent: true),
          _amount('Total balance', r.totalBalance, bold: true),
        ],
      ),
    );
  }

  pw.Widget _info(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10.5,
              color: _ink,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _amount(String label, int value, {bool bold = false, bool accent = false}) {
    final color = accent ? _accent : _ink;
    final style = pw.TextStyle(
      fontSize: 9.5,
      color: color,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    final text = value < 0 ? '- Rs ${_money(-value)}' : 'Rs ${_money(value)}';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(text, style: style)],
      ),
    );
  }

  String _money(int v) => NumberFormat.decimalPattern('en_US').format(v);
}
