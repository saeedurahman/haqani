import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/app_date_utils.dart';
import '../../exams/domain/exam_models.dart';
import '../domain/report_models.dart';
import '../domain/report_pdf_service.dart';

/// Any report as a PDF table. Wide reports are printed sideways.
class ReportPdf implements ReportPdfService {
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
  Future<Uint8List> build(ReportDocument document, SchoolInfo school) async {
    await _loadFonts();
    final wide = document.tables.any((t) => t.columns.length > 7);
    final doc = pw.Document(
      title: document.title,
      theme: pw.ThemeData.withFont(base: _regular!, bold: _bold!, fontFallback: [_urdu!]),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: wide ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => _header(document, school),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
        ),
        build: (_) => [
          if (document.stats.isNotEmpty) _stats(document.stats),
          for (final table in document.tables) ..._table(table),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _header(ReportDocument d, SchoolInfo school) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    school.name,
                    style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: _accent),
                  ),
                  if (school.address.isNotEmpty)
                    pw.Text(school.address, style: const pw.TextStyle(fontSize: 9, color: _muted)),
                ],
              ),
              pw.Text(
                'Printed ${AppDateUtils.toDisplay(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: _accent, thickness: 1.2, height: 1.2),
          pw.SizedBox(height: 8),
          pw.Text(d.title, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _ink)),
          if (d.subtitle.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(d.subtitle, style: const pw.TextStyle(fontSize: 10, color: _muted)),
            ),
        ],
      ),
    );
  }

  pw.Widget _stats(List<ReportStat> stats) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in stats)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(color: _soft, borderRadius: pw.BorderRadius.circular(5)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(s.label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
                  pw.Text(
                    s.value,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _ink),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<pw.Widget> _table(ReportTable t) {
    pw.Widget cell(String text, ReportColumn c, {bool header = false, bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: pw.Text(
          text,
          textAlign: c.type.alignsRight ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: header || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: header ? PdfColors.white : _ink,
          ),
        ),
      );
    }

    final widths = {
      for (var i = 0; i < t.columns.length; i++) i: pw.FlexColumnWidth(t.columns[i].flex.toDouble()),
    };
    return [
      if (t.heading != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 6),
          child: pw.Text(
            t.heading!,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _accent),
          ),
        ),
      if (t.rows.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text('No records.', style: const pw.TextStyle(fontSize: 10, color: _muted)),
        )
      else
        pw.Table(
          columnWidths: widths,
          border: pw.TableBorder(
            horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            bottom: const pw.BorderSide(color: PdfColors.grey400, width: 0.6),
          ),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _accent),
              children: [for (final c in t.columns) cell(c.label, c, header: true)],
            ),
            for (var r = 0; r < t.rows.length; r++)
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: r.isOdd ? const PdfColor.fromInt(0xFFF8F8FC) : null,
                ),
                children: [
                  for (var i = 0; i < t.columns.length; i++)
                    cell(t.rows[r][i], t.columns[i], bold: t.boldLastRow && r == t.rows.length - 1),
                ],
              ),
          ],
        ),
      pw.SizedBox(height: 14),
    ];
  }
}
