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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
