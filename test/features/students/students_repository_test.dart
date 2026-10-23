import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart' hide Student;
import 'package:haqani/features/students/data/students_repository_impl.dart';
import 'package:haqani/features/students/domain/student.dart';
import 'package:haqani/features/students/domain/students_exception.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late StudentsRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('students_test');
    repo = StudentsRepositoryImpl(db, documentsRoot: () async => tempDir);
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Student student(String no, String name,
          {String father = '', int? classId, int? sectionId}) =>
      Student(
        admissionNo: no,
        name: name,
        fatherName: father,
        classId: classId,
        sectionId: sectionId,
      );

  group('save', () {
    test('saves every field and reads it back with class and section', () async {
      final classId = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 1'),
          );
      final sectionId = await db.into(db.sections).insert(
            SectionsCompanion.insert(classId: classId, name: 'A'),
          );

      final id = await repo.saveStudent(Student(
        admissionNo: ' 101 ',
        registrationNo: 'R-9',
        name: ' Ayesha Khan ',
        fatherName: 'Imran Khan',
        fatherCnic: '12345-1234567-1',
        dob: DateTime(2018, 3, 5),
        gender: 'female',
        phone: '0300-1234567',
        whatsappNo: '0321-7654321',
        address: 'Lahore',
        fatherProfession: 'Shopkeeper',
        fatherEducation: 'Matric',
        previousSchool: 'ABC School',
        previousClass: 'Nursery',
        classId: classId,
        sectionId: sectionId,
        admissionDate: DateTime(2026, 4, 1),
        notes: 'Needs front seat',
      ));

      final saved = (await repo.getStudent(id))!;
      expect(saved.admissionNo, '101');
      expect(saved.name, 'Ayesha Khan');
      expect(saved.dob, DateTime(2018, 3, 5));
      expect(saved.gender, 'female');
      expect(saved.admissionDate, DateTime(2026, 4, 1));
      expect(saved.classLabel, 'Class 1 - A');
      expect(saved.status, 'active');
      expect(saved.notes, 'Needs front seat');
    });

    test('requires admission number and name', () async {
      expect(() => repo.saveStudent(student('', 'Ali')), throwsA(isA<StudentsException>()));
      expect(() => repo.saveStudent(student('1', '  ')), throwsA(isA<StudentsException>()));
    });

    test('rejects a repeated admission number but allows keeping your own', () async {
      final id = await repo.saveStudent(student('1', 'Ali'));

      expect(() => repo.saveStudent(student('1', 'Sara')),
          throwsA(isA<StudentsException>()));

      await repo.saveStudent(Student(id: id, admissionNo: '1', name: 'Ali Raza'));
      expect((await repo.getStudent(id))!.name, 'Ali Raza');
    });

    test('editing keeps status and leaving date', () async {
      final id = await repo.saveStudent(student('1', 'Ali'));
      await repo.markAsLeft(id, DateTime(2026, 6, 1));

      await repo.saveStudent(Student(id: id, admissionNo: '1', name: 'Ali R'));

      final s = (await repo.getStudent(id))!;
      expect(s.status, 'left');
      expect(s.leavingDate, DateTime(2026, 6, 1));
    });
  });

  group('search', () {
    setUp(() async {
      final c1 = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 1'),
          );
      final c2 = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 2'),
          );
      await repo.saveStudent(student('1', 'Ali Raza', father: 'Raza Ahmed', classId: c1));
      await repo.saveStudent(student('2', 'Sara Noor', father: 'Noor Khan', classId: c1));
      await repo.saveStudent(student('3', 'Bilal Khan', father: 'Khan Sahib', classId: c2));
    });

    test('lists everyone sorted by name when nothing is typed', () async {
      final all = await repo.searchStudents();
      expect(all.map((s) => s.name), ['Ali Raza', 'Bilal Khan', 'Sara Noor']);
    });

    test('finds by name, father name and admission number', () async {
      expect((await repo.searchStudents(query: 'sara')).single.name, 'Sara Noor');
      expect(
        (await repo.searchStudents(query: 'khan')).map((s) => s.name),
        ['Bilal Khan', 'Sara Noor'],
        reason: 'Bilal by name and father, Sara by father',
      );
      expect((await repo.searchStudents(query: '3')).single.name, 'Bilal Khan');
    });

    test('filters by class', () async {
      final c2 = (await repo.getClassOptions()).last.id;
      expect((await repo.searchStudents(classId: c2)).single.name, 'Bilal Khan');
    });

    test('hides students who left unless asked', () async {
      final ali = (await repo.searchStudents(query: 'Ali')).single;
      await repo.markAsLeft(ali.id, DateTime(2026, 6, 1));

      expect(await repo.searchStudents(), hasLength(2));
      expect(await repo.searchStudents(includeLeft: true), hasLength(3));

      await repo.reactivate(ali.id);
      expect(await repo.searchStudents(), hasLength(3));
      expect((await repo.getStudent(ali.id))!.leavingDate, isNull);
    });
  });

  test('suggests the next admission number from the biggest number', () async {
    expect(await repo.suggestAdmissionNo(), '1');

    await repo.saveStudent(student('7', 'A'));
    await repo.saveStudent(student('X-12', 'B'));
    await repo.saveStudent(student('3', 'C'));

    expect(await repo.suggestAdmissionNo(), '8');
  });

  test('class options list classes with their sections in order', () async {
    final c = await db.into(db.schoolClasses).insert(
          SchoolClassesCompanion.insert(name: 'Class 1'),
        );
    await db.into(db.sections).insert(SectionsCompanion.insert(classId: c, name: 'B'));
    await db.into(db.sections).insert(SectionsCompanion.insert(classId: c, name: 'A'));

    final options = await repo.getClassOptions();

    expect(options.single.name, 'Class 1');
    expect(options.single.sections.map((s) => s.name), ['A', 'B']);
  });

  group('documents', () {
    late int studentId;
    late File source;

    setUp(() async {
      studentId = await repo.saveStudent(student('1', 'Ali'));
      source = File('${tempDir.path}${Platform.pathSeparator}bform.txt')
        ..writeAsStringSync('hello');
    });

    test('copies the file and lists it', () async {
      await repo.addDocument(studentId, ' B-Form ', source.path);

      final docs = await repo.getDocuments(studentId);
      expect(docs.single.title, 'B-Form');
      expect(docs.single.filePath, isNot(source.path));
      expect(File(docs.single.filePath).readAsStringSync(), 'hello');
    });

    test('deleting removes the row and the copied file, not the original', () async {
      await repo.addDocument(studentId, 'B-Form', source.path);
      final doc = (await repo.getDocuments(studentId)).single;

      await repo.deleteDocument(doc.id);

      expect(await repo.getDocuments(studentId), isEmpty);
      expect(File(doc.filePath).existsSync(), isFalse);
      expect(source.existsSync(), isTrue);
    });

    test('rejects an empty title or a missing file', () async {
      expect(() => repo.addDocument(studentId, ' ', source.path),
          throwsA(isA<StudentsException>()));
      expect(() => repo.addDocument(studentId, 'X', '${tempDir.path}/nope.txt'),
          throwsA(isA<StudentsException>()));
    });
  });

  test('history returns attendance, fees and results of that student only', () async {
    final a = await repo.saveStudent(student('1', 'Ali'));
    final b = await repo.saveStudent(student('2', 'Sara'));
    final classId = await db.into(db.schoolClasses).insert(
          SchoolClassesCompanion.insert(name: 'Class 1'),
        );
    await db.into(db.attendance).insert(
        AttendanceCompanion.insert(studentId: a, date: '2026-05-01', status: 'present'));
    await db.into(db.attendance).insert(
        AttendanceCompanion.insert(studentId: a, date: '2026-05-02', status: 'absent'));
    await db.into(db.attendance).insert(
        AttendanceCompanion.insert(studentId: b, date: '2026-05-01', status: 'present'));
    await db.into(db.feeVouchers).insert(FeeVouchersCompanion.insert(
          receiptNo: 'R1',
          date: '2026-05-03',
          studentId: a,
          forMonth: '2026-05',
          total: const Value(1500),
          paidAmount: const Value(1000),
          status: const Value('partial'),
        ));
    final exam = await db.into(db.exams).insert(
          ExamsCompanion.insert(name: 'Annual', classId: classId),
        );
    final subject = await db.into(db.subjects).insert(
          SubjectsCompanion.insert(classId: classId, name: 'Math', totalMarks: const Value(50)),
        );
    await db.into(db.results).insert(ResultsCompanion.insert(
          examId: exam,
          studentId: a,
          subjectId: subject,
          obtainedMarks: const Value(42),
        ));

    final history = await repo.getHistory(a);

    expect(history.attendance.map((r) => r.status), ['absent', 'present'],
        reason: 'newest day first');
    expect(history.countAttendance('present'), 1);
    expect(history.fees.single.due, 500);
    expect(history.results.single.examName, 'Annual');
    expect(history.results.single.totalMarks, 50);
    expect((await repo.getHistory(b)).fees, isEmpty);
  });
}
