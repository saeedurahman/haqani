import 'dart:convert';
import 'dart:typed_data';

import 'report_models.dart';

/// Writes a report as a CSV file that Excel opens correctly.
class ReportCsv {
  const ReportCsv._();

  static String encode(ReportDocument doc) {
    final lines = <String>[
      _line([doc.title]),
      if (doc.subtitle.isNotEmpty) _line([doc.subtitle]),
      if (doc.stats.isNotEmpty) ...[
        '',
        for (final s in doc.stats) _line([s.label, s.value]),
      ],
    ];
    for (final table in doc.tables) {
      lines.add('');
      if (table.heading != null) lines.add(_line([table.heading!]));
      lines.add(_line([for (final c in table.columns) c.label]));
      for (final row in table.rows) {
        lines.add(
          _line([
            for (var i = 0; i < row.length; i++)
              table.columns[i].type == ColumnType.money
                  ? _digits(row[i])
                  : row[i],
          ]),
        );
      }
    }
    return lines.join('\r\n');
  }

  /// UTF-8 with a byte order mark, so Excel shows Urdu names correctly.
  static Uint8List bytes(ReportDocument doc) {
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(encode(doc))]);
  }

  /// "Rs 1,500" -> "1500", "- Rs 200" -> "-200".
  static String _digits(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return text;
    return text.trim().startsWith('-') ? '-$digits' : digits;
  }

  static String _line(List<String> cells) => cells.map(_cell).join(',');

  static String _cell(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    return needsQuotes ? '"${value.replaceAll('"', '""')}"' : value;
  }
}
