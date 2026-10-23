import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/attendance_dao.dart';
import 'daos/classes_dao.dart';
import 'daos/fees_dao.dart';
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
  daos: [ClassesDao, StudentsDao, AttendanceDao, FeesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests with an in-memory database.
  AppDatabase.forTesting(super.executor);

  static const databaseFileName = 'school.sqlite';

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
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dir.path, 'RozatulAtfal', AppDatabase.databaseFileName),
    );
    await file.parent.create(recursive: true);
    return NativeDatabase.createInBackground(file);
  });
}
