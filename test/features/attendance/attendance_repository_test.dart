import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/attendance/data/attendance_repository_impl.dart';
import 'package:haqani/features/attendance/domain/attendance_models.dart';

void main() {
  late AppDatabase db;
  late AttendanceRepositoryImpl repo;
  late int classId;
  late int sectionA;
  late int sectionB;
  late int ali;
  late int sara;
  late int zain;

  Future<int> addStudent(String no, String name,
      {int? cls, int? section, String status = 'active'}) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: no,
          name: name,
          classId: Value(cls),
          sectionId: Value(section),
          status: Value(status),
        ));
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AttendanceRepositoryImpl(db);
    classId = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    sectionA = await db.into(db.sections).insert(SectionsCompanion.insert(classId: classId, name: 'A'));
    sectionB = await db.into(db.sections).insert(SectionsCompanion.insert(classId: classId, name: 'B'));
    ali = await addStudent('1', 'Ali', cls: classId, section: sectionA);
    sara = await addStudent('2', 'Sara', cls: classId, section: sectionB);
    zain = await addStudent('3', 'Zain', cls: classId, section: sectionA);
    // Students who must never appear: left, and another class.
    await addStudent('4', 'Left Boy', cls: classId, section: sectionA, status: 'left');
    final other = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 2'));
    await addStudent('5', 'Other', cls: other);
  });

  tearDown(() => db.close());

  final day = DateTime(2026, 5, 12);

  test('class options list classes with sections', () async {
    final options = await repo.getClassOptions();

    expect(options.map((c) => c.name), ['Class 1', 'Class 2']);
    expect(options.first.sections.map((s) => s.name), ['A', 'B']);
  });

  group('daily sheet', () {
    test('lists active students of the class sorted by name, nothing marked', () async {
      final sheet = await repo.getDailySheet(classId, null, day);

      expect(sheet.map((e) => e.name), ['Ali', 'Sara', 'Zain']);
      expect(sheet.every((e) => e.status == null), isTrue);
    });

    test('filters by section', () async {
      final sheet = await repo.getDailySheet(classId, sectionA, day);

      expect(sheet.map((e) => e.name), ['Ali', 'Zain']);
    });

    test('save then load returns the saved statuses', () async {
      final sheet = await repo.getDailySheet(classId, null, day);
      await repo.saveDailySheet(day, [
        sheet[0].withStatus(AttendanceStatus.present),
        sheet[1].withStatus(AttendanceStatus.absent),
        sheet[2].withStatus(AttendanceStatus.leave),
      ]);

      final loaded = await repo.getDailySheet(classId, null, day);

      expect(loaded.map((e) => e.status), ['present', 'absent', 'leave']);
      expect((await repo.getDailySheet(classId, null, DateTime(2026, 5, 13))).first.status, isNull);
    });

    test('saving the same day again replaces it, never duplicates', () async {
      var sheet = await repo.getDailySheet(classId, null, day);
      await repo.saveDailySheet(day, [for (final e in sheet) e.withStatus('present')]);

      sheet = await repo.getDailySheet(classId, null, day);
      await repo.saveDailySheet(day, [sheet[1].withStatus('absent')]);

      final loaded = await repo.getDailySheet(classId, null, day);
      expect(loaded.map((e) => e.status), ['present', 'absent', 'present']);
      expect(await db.select(db.attendance).get(), hasLength(3));
    });

    test('entries without a status are not saved', () async {
      final sheet = await repo.getDailySheet(classId, null, day);

      await repo.saveDailySheet(day, sheet);

      expect(await db.select(db.attendance).get(), isEmpty);
    });

    test('keeps the note of an entry', () async {
      await db.into(db.attendance).insert(AttendanceCompanion.insert(
            studentId: ali,
            date: '2026-05-12',
            status: 'leave',
            note: const Value('Fever'),
          ));

      final loaded = await repo.getDailySheet(classId, null, day);
      expect(loaded.first.note, 'Fever');

      await repo.saveDailySheet(day, [loaded.first.withStatus('absent')]);
      expect((await repo.getDailySheet(classId, null, day)).first.note, 'Fever');
    });
  });

  group('monthly report', () {
    Future<void> mark(int id, String date, String status) {
      return db.into(db.attendance).insert(
            AttendanceCompanion.insert(studentId: id, date: date, status: status),
          );
    }

    test('counts each status and percent per student for the month only', () async {
      await mark(ali, '2026-05-01', 'present');
      await mark(ali, '2026-05-02', 'present');
      await mark(ali, '2026-05-03', 'present');
      await mark(ali, '2026-05-04', 'absent');
      await mark(ali, '2026-04-30', 'absent');
      await mark(ali, '2026-06-01', 'absent');
      await mark(sara, '2026-05-01', 'leave');

      final rows = await repo.getMonthlyReport(classId, null, 2026, 5);

      expect(rows.map((r) => r.name), ['Ali', 'Sara', 'Zain']);
      final a = rows[0];
      expect((a.present, a.absent, a.leave, a.markedDays), (3, 1, 0, 4));
      expect(a.percent, 75);
      expect(a.days[4], 'absent');
      expect(rows[1].leave, 1);
      expect(rows[1].percent, 0);
      expect(rows[2].markedDays, 0, reason: 'Zain has nothing marked');
      expect(rows[2].percent, 0);
    });

    test('filters by section and ignores students who left', () async {
      final rows = await repo.getMonthlyReport(classId, sectionA, 2026, 5);

      expect(rows.map((r) => r.name), ['Ali', 'Zain']);
      expect(zain, isNonZero);
    });
  });
}
