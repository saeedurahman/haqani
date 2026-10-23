import 'package:intl/intl.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../fees/domain/fee_models.dart';
import '../../fees/domain/fees_repository.dart';
import '../../students/domain/students_repository.dart';
import '../domain/report_models.dart';
import 'report_columns.dart';

/// The fee paid / unpaid and defaulters reports.
class FeeReports {
  FeeReports(this._students, this._fees);

  final StudentsRepository _students;
  final FeesRepository _fees;

  Future<ReportDocument> feesReport({
    required String month,
    int? classId,
    String? status,
  }) async {
    final classes = await _students.getClassOptions();
    final scope = classId == null
        ? classes
        : classes.where((c) => c.id == classId).toList();

    final all = <FeeVoucher>[];
    for (final c in scope) {
      all.addAll(await _fees.getVouchers(month: month, classId: c.id));
    }
    final vouchers = status == null
        ? all
        : all.where((v) => v.status == status).toList();

    final billed = vouchers.fold<int>(0, (s, v) => s + v.total);
    final collected = vouchers.fold<int>(0, (s, v) => s + v.paidAmount);
    final monthName = DateFormat('MMMM yyyy')
        .format(DateTime.parse('$month-01'));
    final classText = classId == null
        ? 'All classes'
        : (scope.firstOrNull?.name ?? '');
    final statusText = status == null
        ? 'all vouchers'
        : '${FeeStatus.label(status).toLowerCase()} only';

    return ReportDocument(
      title: 'Fee Report',
      subtitle: '$monthName  |  $classText  |  $statusText',
      stats: [
        ReportStat('Vouchers', '${vouchers.length}'),
        ReportStat('Billed', MoneyUtils.format(billed)),
        ReportStat('Collected', MoneyUtils.format(collected)),
        ReportStat('Pending', MoneyUtils.format(billed - collected)),
      ],
      tables: [
        ReportTable(
          columns: const [
            ReportColumns.id,
            ReportColumns.student,
            ReportColumn('Class', flex: 2),
            ReportColumn('Total', type: ColumnType.money, flex: 2),
            ReportColumn('Paid', type: ColumnType.money, flex: 2),
            ReportColumn('Balance', type: ColumnType.money, flex: 2),
            ReportColumn('Status', flex: 2),
          ],
          rows: [
            for (final v in vouchers)
              [
                v.student.admissionNo,
                v.student.name,
                v.student.classLabel,
                MoneyUtils.format(v.total),
                MoneyUtils.format(v.paidAmount),
                MoneyUtils.format(v.balance),
                FeeStatus.label(v.status),
              ],
          ],
        ),
      ],
    );
  }

  Future<ReportDocument> defaultersReport({int? classId}) async {
    final defaulters = await _fees.getDefaulters(classId: classId);
    final pending = defaulters.fold<int>(0, (s, d) => s + d.balance);
    final classes = await _students.getClassOptions();
    final className = classId == null
        ? 'All classes'
        : (classes.where((c) => c.id == classId).firstOrNull?.name ?? '');

    return ReportDocument(
      title: 'Fee Defaulters',
      subtitle: '$className  |  ${AppDateUtils.toDisplay(DateTime.now())}',
      stats: [
        ReportStat('Students who owe fee', '${defaulters.length}'),
        ReportStat('Total pending', MoneyUtils.format(pending)),
      ],
      tables: [
        ReportTable(
          columns: const [
            ReportColumns.id,
            ReportColumns.student,
            ReportColumn('Father', flex: 3),
            ReportColumn('Class', flex: 2),
            ReportColumn('Months', type: ColumnType.number),
            ReportColumn('Balance', type: ColumnType.money, flex: 2),
          ],
          rows: [
            for (final d in defaulters)
              [
                d.student.admissionNo,
                d.student.name,
                d.student.fatherName,
                d.student.classLabel,
                '${d.monthsPending}',
                MoneyUtils.format(d.balance),
              ],
          ],
        ),
      ],
    );
  }
}
