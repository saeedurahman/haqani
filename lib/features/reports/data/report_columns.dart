import '../domain/report_models.dart';

/// Columns that several reports share.
class ReportColumns {
  const ReportColumns._();

  static const id = ReportColumn('ID', flex: 1);
  static const student = ReportColumn('Student', flex: 3);
}
