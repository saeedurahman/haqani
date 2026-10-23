import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<DashboardSummary> loadSummary(DateTime today) async {
    final schoolName = await _setting(AppConstants.settingSchoolName);
    final lastBackup = await _setting(AppConstants.settingLastBackup);

    return DashboardSummary(
      schoolName: (schoolName == null || schoolName.isEmpty)
          ? AppStrings.defaultSchoolName
          : schoolName,
      totalStudents: await _activeStudents(),
      totalStaff: await _activeStaff(),
      presentToday: await _presentOn(AppDateUtils.toIso(today)),
      feesCollectedThisMonth: await _collectedIn(AppDateUtils.toMonth(today)),
      lastBackup: AppDateUtils.tryParseIso(lastBackup),
    );
  }

  Future<String?> _setting(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<int> _activeStudents() async {
    final count = _db.students.id.count();
    final query = _db.selectOnly(_db.students)
      ..addColumns([count])
      ..where(_db.students.status.equals('active'));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> _activeStaff() async {
    final count = _db.staff.id.count();
    final query = _db.selectOnly(_db.staff)
      ..addColumns([count])
      ..where(_db.staff.isActive.equals(true));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> _presentOn(String isoDate) async {
    final count = _db.attendance.id.count();
    final query = _db.selectOnly(_db.attendance)
      ..addColumns([count])
      ..where(_db.attendance.date.equals(isoDate) &
          _db.attendance.status.equals('present'));
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> _collectedIn(String month) async {
    final sum = _db.feeVouchers.paidAmount.sum();
    final query = _db.selectOnly(_db.feeVouchers)
      ..addColumns([sum])
      ..where(_db.feeVouchers.date.like('$month-%'));
    return (await query.getSingle()).read(sum) ?? 0;
  }
}
