import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../services/app_paths.dart';
import 'daos/attendance_dao.dart';
import 'daos/classes_dao.dart';
import 'daos/exams_dao.dart';
import 'daos/fees_dao.dart';
import 'daos/staff_dao.dart';
import 'daos/students_dao.dart';
import 'tables/fee_exam_tables.dart';
import 'tables/school_tables.dart';
import 'tables/student_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SchoolClasses,
    Sections,
    Staff,
    AppSettings,
    Students,
    StudentDocuments,
    Attendance,
    FeeStructure,
    FeeVouchers,
    FeePayments,
    Exams,
    Subjects,
    Results,
  ],
  daos: [ClassesDao, StudentsDao, AttendanceDao, FeesDao, StaffDao, ExamsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests with an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  /// Version 2: every payment gets its own row. Money already taken on a
  /// voucher becomes one payment with the voucher's receipt number and date,
  /// then the old receipt number is cleared from the voucher.
  Future<void> _addFeePayments(Migrator m) async {
    await m.createTable(feePayments);
    await customStatement(
      'INSERT INTO fee_payments (voucher_id, receipt_no, date, amount, note) '
      "SELECT id, receipt_no, date, paid_amount, '' FROM fee_vouchers "
      'WHERE paid_amount > 0 ORDER BY id',
    );
    await customStatement("UPDATE fee_vouchers SET receipt_no = ''");
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await _addFeePayments(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await AppPaths().databaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
