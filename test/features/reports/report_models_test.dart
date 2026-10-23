import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/reports/domain/report_csv.dart';
import 'package:haqani/features/reports/domain/report_models.dart';

void main() {
  const doc = ReportDocument(
    title: 'Fee Report',
    subtitle: 'May 2026, "All classes"',
    stats: [ReportStat('Billed', 'Rs 4,500')],
    tables: [
      ReportTable(
        heading: 'Vouchers',
        columns: [
          ReportColumn('Student', flex: 3),
          ReportColumn('Total', type: ColumnType.money),
          ReportColumn('Days', type: ColumnType.number),
        ],
        rows: [
          ['Ali, Raza', 'Rs 1,500', '20'],
          ['Sara "Noor"', '- Rs 200', '18'],
          ['عائشہ', 'Rs 0', '5'],
        ],
      ),
      ReportTable(
        heading: 'Summary',
        columns: [ReportColumn('Class')],
        rows: [['Class 1'], ['Total']],
        searchable: false,
      ),
    ],
  );

  group('ReportCsv', () {
    test('writes title, stats, headings, headers and rows', () {
      final lines = ReportCsv.encode(doc).split('\r\n');

      expect(lines[0], 'Fee Report');
      expect(lines[1], '"May 2026, ""All classes"""');
      expect(lines, contains('Billed,"Rs 4,500"'));
      expect(lines, contains('Vouchers'));
      expect(lines, contains('Student,Total,Days'));
    });

    test('quotes commas and quotes, writes money as plain numbers', () {
      final text = ReportCsv.encode(doc);

      expect(text, contains('"Ali, Raza",1500,20'));
      expect(text, contains('"Sara ""Noor""",-200,18'));
      expect(text, contains('عائشہ,0,5'));
    });

    test('bytes start with a UTF-8 byte order mark and decode back', () {
      final bytes = ReportCsv.bytes(doc);

      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes.skip(3).toList()), ReportCsv.encode(doc));
    });
  });

  group('ReportDocument.filtered', () {
    test('keeps matching rows of searchable tables, in any column, ignoring case', () {
      final result = doc.filtered('SARA');

      expect(result.tables.first.rows, [
        ['Sara "Noor"', '- Rs 200', '18'],
      ]);
      expect(doc.filtered('1,500').tables.first.rows.single.first, 'Ali, Raza');
    });

    test('does not touch tables that are not searchable', () {
      expect(doc.filtered('zzz').tables.last.rows, hasLength(2));
      expect(doc.filtered('zzz').tables.first.rows, isEmpty);
    });

    test('empty search returns the same report', () {
      expect(doc.filtered('  '), same(doc));
    });
  });

  test('rowCount adds all tables', () {
    expect(doc.rowCount, 5);
  });
}
