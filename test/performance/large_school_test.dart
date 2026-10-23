import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/admissions/data/admissions_repository_impl.dart';
import 'package:haqani/features/attendance/data/attendance_repository_impl.dart';
import 'package:haqani/features/classes/data/classes_repository_impl.dart';
import 'package:haqani/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:haqani/features/exams/data/exams_repository_impl.dart';
import 'package:haqani/features/fees/data/fees_repository_impl.dart';
import 'package:haqani/features/reports/data/reports_repository_impl.dart';
import 'package:haqani/features/students/data/students_repository_impl.dart';

/// 1,500 students with a year of history. Every screen's main query must stay quick.
void main() {
  const studentCount = 1500;
  const classCount = 12;
  const limit = Duration(milliseconds: 1500);

  late AppDatabase db;
  late StudentsRepositoryImpl students;
  late FeesRepositoryImpl fees;
  late ExamsRepositoryImpl exams;
  late AttendanceRepositoryImpl attendance;
  late AdmissionsRepositoryImpl admissions;
  late ReportsRepositoryImpl reports;
  final today = DateTime(2026, 5, 20);
  late int firstClassId;
  late int examId;

  setUpAll(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    students = StudentsRepositoryImpl(db);
    fees = FeesRepositoryImpl(db, clock: () => today);
    exams = ExamsRepositoryImpl(db);
    attendance = AttendanceRepositoryImpl(db);
    admissions = AdmissionsRepositoryImpl(db, students);
    reports = ReportsRepositoryImpl(
      students: students,
      admissions: admissions,
      attendance: attendance,
      fees: fees,
      exams: exams,
    );

    final classIds = <int>[];
    for (var c = 0; c < classCount; c++) {
      final id = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class ${c + 1}', sortOrder: Value(c)),
          );
      classIds.add(id);
      await fees.saveFeeStructure(id, 1000 + c * 100, 0, 0);
    }
    firstClassId = classIds.first;

    await db.batch((b) {
      b.insertAll(db.students, [
        for (var i = 0; i < studentCount; i++)
          StudentsCompanion.insert(
            admissionNo: '${i + 1}',
            name: 'Student ${i + 1}',
            fatherName: Value('Father ${i ~/ 2}'),
            classId: Value(classIds[i % classCount]),
            gender: Value(i.isEven ? 'male' : 'female'),
            admissionDate: Value('2025-0${1 + i % 9}-10'),
          ),
      ]);
    });
    final ids = [for (final s in await db.select(db.students).get()) s.id];

    // Attendance: 20 school days for everyone.
    await db.batch((b) {
      for (var day = 1; day <= 20; day++) {
        b.insertAll(db.attendance, [
          for (final id in ids)
            AttendanceCompanion.insert(
              studentId: id,
              date: '2026-05-${day.toString().padLeft(2, '0')}',
              status: id % 7 == day % 7 ? 'absent' : 'present',
            ),
        ]);
      }
    });

    // Fees: vouchers for 6 months; some students pay, some do not.
    for (final month in ['2026-01', '2026-02', '2026-03', '2026-04', '2026-05']) {
      for (final c in classIds) {
        await fees.generateVouchers(classId: c, month: month);
      }
    }
    final vouchers = await db.select(db.feeVouchers).get();
    await db.batch((b) {
      for (final v in vouchers.where((v) => v.studentId % 3 == 0)) {
        b.update(
          db.feeVouchers,
          FeeVouchersCompanion(
            paidAmount: Value(v.total),
            status: const Value('paid'),
            receiptNo: Value('${v.id}'),
          ),
          where: (t) => t.id.equals(v.id),
        );
      }
    });

    // Exam with 6 subjects for every class; marks for every student.
    await db.into(db.exams).insert(ExamsCompanion.insert(name: 'Annual', classId: firstClassId));
    examId = (await db.select(db.exams).get()).single.id;
    final subjectIds = <int>[];
    for (var s = 0; s < 6; s++) {
      subjectIds.add(await db.into(db.subjects).insert(
            SubjectsCompanion.insert(classId: firstClassId, name: 'Subject $s'),
          ));
    }
    final inFirst = await db.studentsDao.search(classId: firstClassId);
    await db.batch((b) {
      b.insertAll(db.results, [
        for (final s in inFirst.map((r) => r.student))
          for (final sub in subjectIds)
            ResultsCompanion.insert(
              examId: examId,
              studentId: s.id,
              subjectId: sub,
              obtainedMarks: Value(30 + (s.id + sub) % 70),
            ),
      ]);
    });
  });

  tearDownAll(() => db.close());

  Future<void> within(String name, Future<void> Function() action) async {
    final watch = Stopwatch()..start();
    await action();
    watch.stop();
    debugPrint('PERF ${name.padRight(34)} ${watch.elapsedMilliseconds} ms');
    expect(watch.elapsed, lessThan(limit), reason: '$name took ${watch.elapsedMilliseconds} ms');
  }

  test('the test data is as big as intended', () async {
    expect((await db.select(db.students).get()).length, studentCount);
    expect((await db.select(db.attendance).get()).length, studentCount * 20);
    expect((await db.select(db.feeVouchers).get()).length, studentCount * 5);
  });

  test('students: list, search by name / father / ID, filter by class', () async {
    await within('students: all', () async {
      expect((await students.searchStudents()).length, studentCount);
    });
    await within('students: search name', () async {
      expect((await students.searchStudents(query: 'Student 77')).isNotEmpty, isTrue);
    });
    await within('students: search father', () async {
      expect((await students.searchStudents(query: 'Father 400')).length, 2);
    });
    await within('students: filter class', () async {
      expect((await students.searchStudents(classId: firstClassId)).length, studentCount ~/ classCount);
    });
    await within('students: next admission no', () async {
      expect(await students.suggestAdmissionNo(), '${studentCount + 1}');
    });
  });

  test('classes, admissions and dashboard', () async {
    await within('classes: list with counts', () async {
      expect((await ClassesRepositoryImpl(db).getClasses()).length, classCount);
    });
    await within('admissions: register', () async {
      expect((await admissions.getAdmissions(query: 'Student 9')).isNotEmpty, isTrue);
    });
    await within('dashboard: summary', () async {
      final s = await DashboardRepositoryImpl(db, fees).loadSummary(today);
      expect(s.totalStudents, studentCount);
      expect(s.defaulters, greaterThan(0));
    });
  });

  test('attendance: daily sheet, save, monthly report', () async {
    await within('attendance: daily sheet', () async {
      expect((await attendance.getDailySheet(firstClassId, null, DateTime(2026, 5, 3))).length, studentCount ~/ classCount);
    });
    await within('attendance: save a class', () async {
      final sheet = await attendance.getDailySheet(firstClassId, null, DateTime(2026, 5, 25));
      await attendance.saveDailySheet(DateTime(2026, 5, 25), [for (final e in sheet) e.withStatus('present')]);
    });
    await within('attendance: monthly report', () async {
      expect((await attendance.getMonthlyReport(firstClassId, null, 2026, 5)).length, studentCount ~/ classCount);
    });
  });

  test('fees: vouchers, family search, defaulters', () async {
    await within('fees: class vouchers', () async {
      expect((await fees.getVouchers(month: '2026-05', classId: firstClassId)).length, studentCount ~/ classCount);
    });
    await within('fees: find student', () async {
      expect((await fees.findStudents('Student 12')).isNotEmpty, isTrue);
    });
    await within('fees: defaulters (all)', () async {
      expect((await fees.getDefaulters()).isNotEmpty, isTrue);
    });
    await within('fees: generate next month', () async {
      final result = await fees.generateVouchers(classId: firstClassId, month: '2026-06');
      expect(result.created, studentCount ~/ classCount);
    });
  });

  test('exams: marks sheet and results for a class', () async {
    await within('exams: marks sheet', () async {
      final sheet = await exams.getMarksSheet(examId);
      expect(sheet.students.length, studentCount ~/ classCount);
    });
  });

  test('reports: the big ones', () async {
    await within('report: students', () async {
      expect((await reports.studentsReport()).rowCount, greaterThan(0));
    });
    await within('report: fees all classes', () async {
      expect((await reports.feesReport(month: '2026-05')).tables.single.rows.length, studentCount);
    });
    await within('report: defaulters', () async {
      expect((await reports.defaultersReport()).rowCount, greaterThan(0));
    });
    await within('report: exam results', () async {
      expect((await reports.examResultsReport(examId)).rowCount, studentCount ~/ classCount);
    });
    await within('report: student history', () async {
      expect((await reports.studentHistoryReport(1)).tables, isNotEmpty);
    });
  });
}
