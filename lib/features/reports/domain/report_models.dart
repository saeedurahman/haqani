import 'package:equatable/equatable.dart';

/// Thrown with a message that is safe to show to the user.
class ReportsException implements Exception {
  const ReportsException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum ColumnType {
  text,
  number,

  /// Shown as "Rs 1,500". In a CSV file only the digits are written.
  money;

  bool get alignsRight => this != text;
}

class ReportColumn extends Equatable {
  const ReportColumn(this.label, {this.type = ColumnType.text, this.flex = 1});

  final String label;
  final ColumnType type;

  /// Relative width on screen and in the PDF.
  final int flex;

  @override
  List<Object?> get props => [label, type, flex];
}

/// A small number shown above the tables, like "Total students: 120".
class ReportStat extends Equatable {
  const ReportStat(this.label, this.value);

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}

class ReportTable extends Equatable {
  const ReportTable({
    this.heading,
    required this.columns,
    required this.rows,
    this.searchable = true,
    this.boldLastRow = false,
  });

  final String? heading;
  final List<ReportColumn> columns;

  /// Every row has one text per column.
  final List<List<String>> rows;

  /// Whether the search box filters this table.
  final bool searchable;

  /// Draws the last row as a total.
  final bool boldLastRow;

  ReportTable copyWith({List<List<String>>? rows}) => ReportTable(
        heading: heading,
        columns: columns,
        rows: rows ?? this.rows,
        searchable: searchable,
        boldLastRow: boldLastRow,
      );

  @override
  List<Object?> get props => [heading, columns, rows, searchable, boldLastRow];
}

/// One report: a title, a few numbers and one or more tables.
class ReportDocument extends Equatable {
  const ReportDocument({
    required this.title,
    this.subtitle = '',
    this.stats = const [],
    required this.tables,
  });

  final String title;
  final String subtitle;
  final List<ReportStat> stats;
  final List<ReportTable> tables;

  int get rowCount => tables.fold(0, (sum, t) => sum + t.rows.length);

  /// Same report with only the rows that contain [query] in any cell.
  /// Tables that are not searchable are kept as they are.
  ReportDocument filtered(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return this;
    return ReportDocument(
      title: title,
      subtitle: subtitle,
      stats: stats,
      tables: [
        for (final t in tables)
          t.searchable
              ? t.copyWith(
                  rows: [
                    for (final row in t.rows)
                      if (row.any((cell) => cell.toLowerCase().contains(q))) row,
                  ],
                )
              : t,
      ],
    );
  }

  @override
  List<Object?> get props => [title, subtitle, stats, tables];
}
