import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/reports/data/report_pdf.dart';
import 'package:haqani/features/reports/domain/report_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const school = SchoolInfo(name: 'Rozatul Atfal', address: 'Iqra Schools Foundation, Lahore');

  ReportDocument doc({int rows = 5, int extraColumns = 0}) {
    return ReportDocument(
      title: 'Fee Report',
      subtitle: 'May 2026  |  All classes',
      stats: const [ReportStat('Billed', 'Rs 4,500'), ReportStat('Pending', 'Rs 1,000')],
      tables: [
        ReportTable(
          heading: 'Vouchers',
          columns: [
            const ReportColumn('ID'),
            const ReportColumn('Student', flex: 3),
            for (var i = 0; i < extraColumns; i++) ReportColumn('C$i', type: ColumnType.number),
            const ReportColumn('Total', type: ColumnType.money),
          ],
          rows: [
            for (var r = 0; r < rows; r++)
              [
                '$r',
                r == 1 ? 'عائشہ خان' : 'Student $r',
                for (var i = 0; i < extraColumns; i++) '$i',
                'Rs ${r * 100}',
              ],
          ],
          boldLastRow: true,
        ),
        const ReportTable(heading: 'Empty', columns: [ReportColumn('A')], rows: []),
      ],
    );
  }

  int pages(List<int> bytes) =>
      RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length;

  test('builds a PDF with Urdu names and an empty table', () async {
    final bytes = await ReportPdf().build(doc(), school);

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(pages(bytes), 1);
  });

  test('a long report runs over several pages', () async {
    final bytes = await ReportPdf().build(doc(rows: 150), school);

    expect(pages(bytes), greaterThan(2));
  });

  test('a wide report is printed sideways', () async {
    final normal = await ReportPdf().build(doc(), school);
    final wide = await ReportPdf().build(doc(extraColumns: 8), school);

    expect(String.fromCharCodes(normal).contains('595'), isTrue, reason: 'A4 portrait width');
    expect(RegExp(r'/MediaBox\s*\[\s*0\s+0\s+841').hasMatch(String.fromCharCodes(wide)), isTrue,
        reason: 'A4 landscape width');
  });

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['REPORT_SAMPLE_PATH'];
    if (path == null) return;
    File(path).writeAsBytesSync(await ReportPdf().build(doc(rows: 12), school));
  });
}
