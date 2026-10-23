import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/database/app_database.dart' hide Student;
import 'package:haqani/features/admissions/data/admissions_repository_impl.dart';
import 'package:haqani/features/students/data/students_repository_impl.dart';
import 'package:haqani/features/students/domain/student.dart';
import 'package:haqani/features/students/domain/students_exception.dart';

void main() {
  late AppDatabase db;
  late StudentsRepositoryImpl students;
  late AdmissionsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    students = StudentsRepositoryImpl(db);
    repo = AdmissionsRepositoryImpl(db, students);
  });

  tearDown(() => db.close());

  Student newStudent(String name, {DateTime? date, int? classId, String no = 'ignored'}) =>
      Student(admissionNo: no, name: name, admissionDate: date, classId: classId);

  group('admit', () {
    test('gives numbers 1, 2, 3 automatically and ignores the typed number', () async {
      final a = await repo.admit(newStudent('Ali', no: '999'));
      final b = await repo.admit(newStudent('Sara'));
      final c = await repo.admit(newStudent('Zain'));

      expect([a.admissionNo, b.admissionNo, c.admissionNo], ['1', '2', '3']);
      expect(await repo.nextAdmissionNo(), '4');
    });

    test('continues after the biggest existing number', () async {
      await students.saveStudent(newStudent('Old', no: '250'));

      expect((await repo.admit(newStudent('New'))).admissionNo, '251');
    });

    test('saves the student with class, section and status active', () async {
      final classId = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 1'),
          );
      final sectionId = await db.into(db.sections).insert(
            SectionsCompanion.insert(classId: classId, name: 'A'),
          );

      final saved = await repo.admit(Student(
        admissionNo: '',
        name: ' Ayesha ',
        fatherName: 'Imran',
        classId: classId,
        sectionId: sectionId,
        admissionDate: DateTime(2026, 4, 1),
      ));

      expect(saved.id, greaterThan(0));
      expect(saved.name, 'Ayesha');
      expect(saved.classLabel, 'Class 1 - A');
      expect(saved.status, 'active');
      expect(saved.admissionDate, DateTime(2026, 4, 1));
    });

    test('refuses an empty name and does not use up a number', () async {
      expect(() => repo.admit(newStudent('  ')), throwsA(isA<StudentsException>()));

      expect(await repo.nextAdmissionNo(), '1');
      expect((await repo.getAdmissions()), isEmpty);
    });
  });

  group('getAdmissions', () {
    test('newest admission first, with search and date range', () async {
      await repo.admit(newStudent('Ali Raza', date: DateTime(2026, 4, 1)));
      await repo.admit(newStudent('Sara Noor', date: DateTime(2026, 5, 10)));
      await repo.admit(newStudent('Zain Ali', date: DateTime(2026, 6, 20)));

      expect((await repo.getAdmissions()).map((s) => s.name),
          ['Zain Ali', 'Sara Noor', 'Ali Raza']);
      expect((await repo.getAdmissions(query: 'ali')).map((s) => s.name),
          ['Zain Ali', 'Ali Raza']);
      expect(
        (await repo.getAdmissions(from: DateTime(2026, 5, 1), to: DateTime(2026, 5, 31)))
            .map((s) => s.name),
        ['Sara Noor'],
      );
      expect((await repo.getAdmissions(from: DateTime(2026, 6, 20))).single.name, 'Zain Ali');
      expect((await repo.getAdmissions(to: DateTime(2026, 4, 1))).single.name, 'Ali Raza');
    });

    test('includes students who have left', () async {
      final s = await repo.admit(newStudent('Ali', date: DateTime(2026, 4, 1)));
      await students.markAsLeft(s.id, DateTime(2026, 6, 1));

      expect((await repo.getAdmissions()).single.status, 'left');
    });
  });

  group('getCertificateDefaults', () {
    final today = DateTime(2026, 7, 1);

    test('fills the certificate from the student record', () async {
      await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.settingSchoolName,
            value: 'Test School',
          ));
      await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.settingSchoolAddress,
            value: 'Main Road, Lahore',
          ));
      final c1 = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 1', sortOrder: const Value(0)),
          );
      await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 2', sortOrder: const Value(1)),
          );
      final saved = await repo.admit(Student(
        admissionNo: '',
        name: 'Ayesha Khan',
        fatherName: 'Imran Khan',
        gender: 'female',
        dob: DateTime(2018, 3, 5),
        classId: c1,
        admissionDate: DateTime(2024, 4, 1),
      ));

      final c = await repo.getCertificateDefaults(saved.id, today);

      expect(c.schoolName, 'Test School');
      expect(c.schoolAddress, 'Main Road, Lahore');
      expect(c.admissionNo, saved.admissionNo);
      expect(c.studentName, 'Ayesha Khan');
      expect(c.fatherName, 'Imran Khan');
      expect(c.gender, 'female');
      expect(c.dob, DateTime(2018, 3, 5));
      expect(c.admissionDate, DateTime(2024, 4, 1));
      expect(c.attendedFrom, DateTime(2024, 4, 1));
      expect(c.attendedTo, today, reason: 'not left yet, so today');
      expect(c.className, 'Class 1');
      expect(c.promotedClass, 'Class 2');
      expect(c.duesCleared, isTrue);
      expect(c.discipline, 'Good');
      expect(c.issueDate, today);
      expect(c.attendance, '');
      expect(c.exam, '');
    });

    test('uses the leaving date when the student has left', () async {
      final s = await repo.admit(newStudent('Ali', date: DateTime(2024, 4, 1)));
      await students.markAsLeft(s.id, DateTime(2026, 6, 1));

      expect((await repo.getCertificateDefaults(s.id, today)).attendedTo, DateTime(2026, 6, 1));
    });

    test('default school name is used when settings are empty', () async {
      final s = await repo.admit(newStudent('Ali'));

      final c = await repo.getCertificateDefaults(s.id, today);

      expect(c.schoolName, 'Rozatul Atfal');
      expect(c.schoolAddress, '');
    });

    test('dues are not cleared when a fee is unpaid, attendance and exam are filled', () async {
      final classId = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 1'),
          );
      final s = await repo.admit(newStudent('Ali', classId: classId));
      await db.into(db.feeVouchers).insert(FeeVouchersCompanion.insert(
            receiptNo: 'R1',
            date: '2026-05-03',
            studentId: s.id,
            forMonth: '2026-05',
            total: const Value(1500),
            paidAmount: const Value(1000),
          ));
      for (final (date, status) in [
        ('2026-05-01', 'present'),
        ('2026-05-02', 'present'),
        ('2026-05-03', 'present'),
        ('2026-05-04', 'absent'),
      ]) {
        await db.into(db.attendance).insert(
              AttendanceCompanion.insert(studentId: s.id, date: date, status: status),
            );
      }
      final exam = await db.into(db.exams).insert(
            ExamsCompanion.insert(name: 'Annual 2026', classId: classId),
          );
      final subject = await db.into(db.subjects).insert(
            SubjectsCompanion.insert(classId: classId, name: 'Math'),
          );
      await db.into(db.results).insert(ResultsCompanion.insert(
            examId: exam,
            studentId: s.id,
            subjectId: subject,
            obtainedMarks: const Value(80),
          ));

      final c = await repo.getCertificateDefaults(s.id, today);

      expect(c.duesCleared, isFalse);
      expect(c.attendance, '75% (3 of 4 days)');
      expect(c.exam, 'Annual 2026');
      expect(c.promotedClass, '', reason: 'last class has no next class');
    });

    test('unknown student is refused', () async {
      expect(() => repo.getCertificateDefaults(99, today), throwsA(isA<StudentsException>()));
    });
  });
}
