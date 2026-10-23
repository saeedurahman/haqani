import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:haqani/features/fees/data/fees_repository_impl.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';

void main() {
  late AppDatabase db;
  late DashboardRepositoryImpl repository;
  final today = DateTime(2026, 5, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DashboardRepositoryImpl(db, FeesRepositoryImpl(db, clock: () => today));
  });

  tearDown(() => db.close());

  Future<int> addStudent(String no, {String status = 'active'}) {
    return db.into(db.students).insert(
          StudentsCompanion.insert(
            admissionNo: no,
            name: 'Student $no',
            status: Value(status),
          ),
        );
  }

  test('empty database gives zeros and the default school name', () async {
    final summary = await repository.loadSummary(today);

    expect(summary.schoolName, AppStrings.defaultSchoolName);
    expect(summary.totalStudents, 0);
    expect(summary.totalStaff, 0);
    expect(summary.presentToday, 0);
    expect(summary.absentToday, 0);
    expect(summary.defaulters, 0);
    expect(summary.pendingFees, 0);
    expect(summary.feesCollectedThisMonth, 0);
    expect(summary.lastBackup, isNull);
  });

  test('counts only active students and active staff', () async {
    await addStudent('1');
    await addStudent('2');
    await addStudent('3', status: 'left');
    await db.into(db.staff).insert(StaffCompanion.insert(name: 'Teacher A'));
    await db.into(db.staff).insert(
          StaffCompanion.insert(name: 'Teacher B', isActive: const Value(false)),
        );

    final summary = await repository.loadSummary(today);

    expect(summary.totalStudents, 2);
    expect(summary.totalStaff, 1);
  });

  test('counts present students for today only', () async {
    final a = await addStudent('1');
    final b = await addStudent('2');
    Future<void> mark(int id, String date, String status) {
      return db.into(db.attendance).insert(
            AttendanceCompanion.insert(studentId: id, date: date, status: status),
          );
    }

    await mark(a, '2026-05-12', 'present');
    await mark(b, '2026-05-12', 'absent');
    await mark(a, '2026-05-11', 'present');

    expect((await repository.loadSummary(today)).presentToday, 1);
  });

  test('sums fees paid this month only', () async {
    final id = await addStudent('1');
    Future<void> voucher(String no, String date, int paid) {
      return db.into(db.feeVouchers).insert(
            FeeVouchersCompanion.insert(
              receiptNo: no,
              date: date,
              studentId: id,
              forMonth: date.substring(0, 7),
              paidAmount: Value(paid),
            ),
          );
    }

    await voucher('R1', '2026-05-02', 1500);
    await voucher('R2', '2026-05-10', 500);
    await voucher('R3', '2026-04-28', 9000);

    expect((await repository.loadSummary(today)).feesCollectedThisMonth, 2000);
  });

  test('reads school name and last backup from settings', () async {
    await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
          key: AppConstants.settingSchoolName,
          value: 'Test School',
        ));
    await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
          key: AppConstants.settingLastBackup,
          value: '2026-05-10T09:30:00.000',
        ));

    final summary = await repository.loadSummary(today);

    expect(summary.schoolName, 'Test School');
    expect(summary.lastBackup, DateTime(2026, 5, 10, 9, 30));
  });

  test('counts absent students for today only', () async {
    final a = await addStudent('1');
    final b = await addStudent('2');
    Future<void> mark(int id, String date, String status) {
      return db.into(db.attendance).insert(
            AttendanceCompanion.insert(studentId: id, date: date, status: status),
          );
    }

    await mark(a, '2026-05-12', 'absent');
    await mark(b, '2026-05-12', 'present');
    await mark(b, '2026-05-11', 'absent');

    final summary = await repository.loadSummary(today);

    expect((summary.presentToday, summary.absentToday), (1, 1));
  });

  test('pending fees: students who owe, and the total', () async {
    final classId = await db.into(db.schoolClasses).insert(
          SchoolClassesCompanion.insert(name: 'Class 1'),
        );
    final fees = FeesRepositoryImpl(db, clock: () => today);
    await fees.saveFeeStructure(classId, 1500, 0, 0);
    for (final no in ['1', '2', '3']) {
      await db.into(db.students).insert(
            StudentsCompanion.insert(admissionNo: no, name: 'S$no', classId: Value(classId)),
          );
    }
    await fees.generateVouchers(classId: classId, month: '2026-05');
    final vouchers = await fees.getVouchers(month: '2026-05', classId: classId);
    await fees.collect([PaymentRequest(voucherId: vouchers[0].id, amount: 1500)], today);
    await fees.collect([PaymentRequest(voucherId: vouchers[1].id, amount: 500)], today);

    final summary = await repository.loadSummary(today);

    expect(summary.defaulters, 2);
    expect(summary.pendingFees, 1000 + 1500);
  });
}
