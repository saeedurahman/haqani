import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart' hide Exam, Subject, Student;
import 'package:haqani/features/admissions/data/admissions_repository_impl.dart';
import 'package:haqani/features/attendance/data/attendance_repository_impl.dart';
import 'package:haqani/features/exams/data/exams_repository_impl.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/fees/data/fees_repository_impl.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:haqani/features/reports/data/reports_repository_impl.dart';
import 'package:haqani/features/reports/domain/report_models.dart';
import 'package:haqani/features/students/data/students_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ReportsRepositoryImpl reports;
  late FeesRepositoryImpl fees;
  late ExamsRepositoryImpl exams;
  late StudentsRepositoryImpl students;
  late int class1;
  late int class2;
  late int sectionA;
  late int ali;
  late int sara;
  final today = DateTime(2026, 5, 10);

  Future<int> add(String no, String name,
      {int? cls, int? section, String gender = 'male', String father = '', String? admitted, String status = 'active'}) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: no,
          name: name,
          classId: Value(cls),
          sectionId: Value(section),
          gender: Value(gender),
          fatherName: Value(father),
          admissionDate: Value(admitted),
          status: Value(status),
        ));
  }

  List<List<String>> rows(ReportDocument d, [int table = 0]) => d.tables[table].rows;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    students = StudentsRepositoryImpl(db);
    fees = FeesRepositoryImpl(db, clock: () => today);
    exams = ExamsRepositoryImpl(db);
    reports = ReportsRepositoryImpl(
      students: students,
      admissions: AdmissionsRepositoryImpl(db, students),
      attendance: AttendanceRepositoryImpl(db),
      fees: fees,
      exams: exams,
    );
    class1 = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    class2 = await db.into(db.schoolClasses).insert(
          SchoolClassesCompanion.insert(name: 'Class 2', sortOrder: const Value(1)),
        );
    sectionA = await db.into(db.sections).insert(SectionsCompanion.insert(classId: class1, name: 'A'));
    ali = await add('1', 'Ali Raza', cls: class1, section: sectionA, father: 'Raza Ahmed', admitted: '2026-04-05');
    sara = await add('2', 'Sara Noor', cls: class1, gender: 'female', father: 'Noor Din', admitted: '2026-05-02');
    await add('3', 'Zoya', cls: class2, gender: 'female', admitted: '2026-05-20');
    await add('4', 'Left Boy', cls: class1, admitted: '2026-05-03', status: 'left');
  });

  tearDown(() => db.close());

  group('students report', () {
    test('class-wise and section-wise counts with totals', () async {
      await add('9', 'No Class Kid');

      final d = await reports.studentsReport();

      expect(d.stats.map((s) => '${s.label}=${s.value}'),
          ['Total students=4', 'Boys=2', 'Girls=2']);
      expect(rows(d), [
        ['Class 1', '1', '1', '2'],
        ['Class 2', '0', '1', '1'],
        ['No class', '1', '0', '1'],
        ['Total', '2', '2', '4'],
      ]);
      expect(rows(d, 1), [
        ['Class 1', 'A', '1', '0', '1'],
        ['Class 1', 'No section', '0', '1', '1'],
        ['Class 2', 'No section', '0', '1', '1'],
        ['No class', 'No section', '1', '0', '1'],
      ]);
      expect(d.tables.first.boldLastRow, isTrue);
    });
  });

  group('admissions report', () {
    test('lists the range, newest first, with status', () async {
      final d = await reports.admissionsReport(from: DateTime(2026, 5, 1), to: DateTime(2026, 5, 31));

      expect(rows(d).map((r) => r[1]), ['Zoya', 'Left Boy', 'Sara Noor']);
      expect(rows(d)[1].last, 'Left');
      expect(d.stats.single.value, '3');
      expect(d.subtitle, '01 May 2026 to 31 May 2026');
    });

    test('no dates means everything', () async {
      final d = await reports.admissionsReport();

      expect(rows(d), hasLength(4));
      expect(d.subtitle, 'All dates');
    });
  });

  group('attendance report', () {
    test('counts per student for the month, with average', () async {
      for (final (id, date, status) in [
        (ali, '2026-05-01', 'present'),
        (ali, '2026-05-02', 'present'),
        (ali, '2026-05-03', 'absent'),
        (ali, '2026-05-04', 'present'),
        (sara, '2026-05-01', 'leave'),
      ]) {
        await db.into(db.attendance).insert(
              AttendanceCompanion.insert(studentId: id, date: date, status: status),
            );
      }

      final d = await reports.attendanceReport(classId: class1, year: 2026, month: 5);

      expect(d.subtitle, 'Class 1, May 2026');
      expect(rows(d), [
        ['1', 'Ali Raza', '3', '1', '0', '4', '75%'],
        ['2', 'Sara Noor', '0', '0', '1', '1', '0%'],
      ]);
      expect(d.stats.last.value, '38%');
    });

    test('section filter, no marks, and a missing class', () async {
      final d = await reports.attendanceReport(classId: class1, sectionId: sectionA, year: 2026, month: 5);

      expect(d.subtitle, 'Class 1 - Section A, May 2026');
      expect(rows(d), [
        ['1', 'Ali Raza', '0', '0', '0', '0', '-'],
      ]);
      expect(d.stats.last.value, '-');
      expect(() => reports.attendanceReport(classId: 99, year: 2026, month: 5),
          throwsA(isA<ReportsException>()));
    });
  });

  group('fee reports', () {
    setUp(() async {
      await fees.saveFeeStructure(class1, 1500, 0, 0);
      await fees.saveFeeStructure(class2, 1000, 0, 0);
      await fees.generateVouchers(classId: class1, month: '2026-05');
      await fees.generateVouchers(classId: class2, month: '2026-05');
    });

    Future<int> voucherOf(int classId, String name) async =>
        (await fees.getVouchers(month: '2026-05', classId: classId))
            .firstWhere((v) => v.student.name == name)
            .id;

    test('month report: all classes, totals and status filter', () async {
      await fees.collect([PaymentRequest(voucherId: await voucherOf(class1, 'Ali Raza'), amount: 1500)], today);
      await fees.collect([PaymentRequest(voucherId: await voucherOf(class1, 'Sara Noor'), amount: 500)], today);

      final all = await reports.feesReport(month: '2026-05');
      expect(all.subtitle, 'May 2026  |  All classes  |  all vouchers');
      expect(all.stats.map((s) => '${s.label}=${s.value}'),
          ['Vouchers=3', 'Billed=Rs 4,000', 'Collected=Rs 2,000', 'Pending=Rs 2,000']);
      expect(rows(all).map((r) => '${r[1]}:${r[6]}'),
          ['Ali Raza:Paid', 'Sara Noor:Partial', 'Zoya:Unpaid']);
      expect(rows(all).first.sublist(3, 6), ['Rs 1,500', 'Rs 1,500', 'Rs 0']);

      final unpaid = await reports.feesReport(month: '2026-05', status: 'unpaid');
      expect(rows(unpaid).map((r) => r[1]), ['Zoya']);
      expect(unpaid.stats[3].value, 'Rs 1,000');

      final oneClass = await reports.feesReport(month: '2026-05', classId: class2);
      expect(rows(oneClass).map((r) => r[1]), ['Zoya']);
      expect(oneClass.subtitle, contains('Class 2'));
    });

    test('defaulters: who owes, months, balance', () async {
      await fees.collect([PaymentRequest(voucherId: await voucherOf(class1, 'Ali Raza'), amount: 1500)], today);
      await fees.collect([PaymentRequest(voucherId: await voucherOf(class1, 'Sara Noor'), amount: 500)], today);

      final d = await reports.defaultersReport();

      expect(rows(d), [
        ['2', 'Sara Noor', 'Noor Din', 'Class 1', '1', 'Rs 1,000'],
        ['3', 'Zoya', '', 'Class 2', '1', 'Rs 1,000'],
      ]);
      expect(d.stats.map((s) => s.value), ['2', 'Rs 2,000']);
      expect(rows(await reports.defaultersReport(classId: class2)).single[1], 'Zoya');
    });
  });

  group('exam results report', () {
    test('ranked rows with subject marks, totals and stats', () async {
      await exams.saveSubject(Subject(classId: class1, name: 'English'));
      await exams.saveSubject(Subject(classId: class1, name: 'Math', totalMarks: 50));
      final subs = await exams.getSubjects(class1);
      await exams.saveExam(Exam(name: 'Annual', classId: class1, date: DateTime(2026, 5, 20)));
      final exam = (await exams.getExams()).single.id;
      await exams.saveMarks(exam, [
        MarkEntry(studentId: ali, subjectId: subs[0].id, marks: 60),
        MarkEntry(studentId: ali, subjectId: subs[1].id, marks: 30),
        MarkEntry(studentId: sara, subjectId: subs[0].id, marks: 90),
        MarkEntry(studentId: sara, subjectId: subs[1].id, marks: 45),
      ]);

      final d = await reports.examResultsReport(exam);

      expect(d.subtitle, 'Annual  |  Class 1  |  20 May 2026');
      expect(d.tables.first.columns.map((c) => c.label),
          ['Pos', 'ID', 'Student', 'English (100)', 'Math (50)', 'Total', '%', 'Grade', 'Result']);
      expect(rows(d), [
        ['1', '2', 'Sara Noor', '90', '45', '135/150', '90.0', 'A+', 'Pass'],
        ['2', '1', 'Ali Raza', '60', '30', '90/150', '60.0', 'B', 'Pass'],
      ]);
      expect(d.stats.map((s) => '${s.label}=${s.value}'),
          ['Students=2', 'Passed=2', 'Failed=0', 'Average=75.0%']);
    });

    test('unknown exam gives a clear error', () async {
      expect(() => reports.examResultsReport(99), throwsA(isA<ReportsException>()));
    });
  });

  group('student history report', () {
    test('profile, attendance by month, fees and exams in one report', () async {
      await db.into(db.attendance).insert(AttendanceCompanion.insert(studentId: ali, date: '2026-04-01', status: 'present'));
      await db.into(db.attendance).insert(AttendanceCompanion.insert(studentId: ali, date: '2026-04-02', status: 'absent'));
      await db.into(db.attendance).insert(AttendanceCompanion.insert(studentId: ali, date: '2026-05-01', status: 'present'));
      await fees.saveFeeStructure(class1, 1500, 0, 0);
      await fees.generateVouchers(classId: class1, month: '2026-04');
      await fees.generateVouchers(classId: class1, month: '2026-05');
      final may = (await fees.getVouchers(month: '2026-05', classId: class1)).firstWhere((v) => v.student.id == ali);
      await fees.collect([PaymentRequest(voucherId: may.id, amount: 1000)], today);
      await exams.saveSubject(Subject(classId: class1, name: 'English'));
      final english = (await exams.getSubjects(class1)).single.id;
      await exams.saveExam(Exam(name: 'Annual', classId: class1));
      await exams.saveMarks((await exams.getExams()).single.id, [
        MarkEntry(studentId: ali, subjectId: english, marks: 85),
      ]);

      final d = await reports.studentHistoryReport(ali);

      expect(d.subtitle, 'Ali Raza  |  ID 1  |  Father: Raza Ahmed');
      expect(d.stats.map((s) => '${s.label}=${s.value}'), [
        'Class=Class 1 - A',
        'Admission date=05 Apr 2026',
        'Status=Active',
        'Attendance=67%',
        'Fee due=Rs 2,000',
      ]);
      expect(rows(d, 0), [
        ['May 2026', '1', '0', '0', '100%'],
        ['April 2026', '1', '1', '0', '50%'],
      ]);
      expect(rows(d, 1).map((r) => '${r[0]}:${r[5]}'), ['2026-05:Partial', '2026-04:Carried forward']);
      expect(rows(d, 2), [
        ['Annual', 'Class 1', '85/100', '85.0', 'A+', '1', 'Pass'],
      ]);
    });

    test('a student with no history gets empty tables, unknown student is refused', () async {
      final d = await reports.studentHistoryReport(sara);
      expect(d.tables.every((t) => t.rows.isEmpty), isTrue);
      expect(d.stats[3].value, '-');

      expect(() => reports.studentHistoryReport(999), throwsA(isA<ReportsException>()));
    });
  });

  test('helpers: classes, exam options, student search, school info', () async {
    expect((await reports.getClassOptions()).map((c) => c.name), ['Class 1', 'Class 2']);
    expect(await reports.getExamOptions(), isEmpty);
    expect((await reports.findStudents('sara')).single.name, 'Sara Noor');
    expect(await reports.findStudents(' '), isEmpty);
    expect((await reports.getSchoolInfo()).name, 'Rozatul Atfal');
  });
}
