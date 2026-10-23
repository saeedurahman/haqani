import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/database/app_database.dart' hide Exam, Subject;
import 'package:haqani/features/exams/data/exams_repository_impl.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/exams/domain/result_calculator.dart';
import 'package:haqani/features/exams/domain/result_card.dart';

void main() {
  late AppDatabase db;
  late ExamsRepositoryImpl repo;
  late int class1;
  late int class2;
  late int ali;
  late int sara;
  late int zain;

  Future<int> addStudent(String no, String name, {int? cls, int? section, String status = 'active'}) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: no,
          name: name,
          classId: Value(cls),
          sectionId: Value(section),
          status: Value(status),
        ));
  }

  Future<int> examId(String name) async =>
      (await repo.getExams()).firstWhere((e) => e.name == name).id;

  Future<List<Subject>> subjectsOf(int cls) => repo.getSubjects(cls);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExamsRepositoryImpl(db);
    class1 = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    class2 = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 2'));
    final sectionA = await db.into(db.sections).insert(SectionsCompanion.insert(classId: class1, name: 'A'));
    ali = await addStudent('1', 'Ali', cls: class1, section: sectionA);
    sara = await addStudent('2', 'Sara', cls: class1);
    zain = await addStudent('3', 'Zain', cls: class1);
    await addStudent('4', 'Left', cls: class1, status: 'left');
    await addStudent('5', 'Other', cls: class2);
  });

  tearDown(() => db.close());

  group('subjects', () {
    test('add, list in order, edit', () async {
      await repo.saveSubject(Subject(classId: class1, name: ' English '));
      await repo.saveSubject(Subject(classId: class1, name: 'Math', totalMarks: 50));

      var list = await subjectsOf(class1);
      expect(list.map((s) => (s.name, s.totalMarks)), [('English', 100), ('Math', 50)]);

      await repo.saveSubject(Subject(id: list[1].id, classId: class1, name: 'Maths', totalMarks: 75));
      list = await subjectsOf(class1);
      expect((list[1].name, list[1].totalMarks), ('Maths', 75));
      expect(await subjectsOf(class2), isEmpty);
    });

    test('refuses empty, duplicate (any letter case) and bad totals', () async {
      await repo.saveSubject(Subject(classId: class1, name: 'English'));

      expect(() => repo.saveSubject(Subject(classId: class1, name: ' ')), throwsA(isA<ExamsException>()));
      expect(() => repo.saveSubject(Subject(classId: class1, name: 'english')), throwsA(isA<ExamsException>()));
      expect(() => repo.saveSubject(Subject(classId: class1, name: 'Urdu', totalMarks: 0)),
          throwsA(isA<ExamsException>()));
      expect(() => repo.saveSubject(Subject(classId: class1, name: 'Urdu', totalMarks: 1001)),
          throwsA(isA<ExamsException>()));
      await repo.saveSubject(Subject(classId: class2, name: 'English'));
    });
  });

  group('exams', () {
    test('create, list newest first with class name, filter and search', () async {
      await repo.saveExam(Exam(name: 'Mid Term', classId: class1, date: DateTime(2026, 3, 1)));
      await repo.saveExam(Exam(name: 'Annual 2026', classId: class1, date: DateTime(2026, 5, 1)));
      await repo.saveExam(Exam(name: 'Annual 2026', classId: class2, date: DateTime(2026, 5, 2)));

      final all = await repo.getExams();
      expect(all.map((e) => '${e.name}/${e.className}'),
          ['Annual 2026/Class 2', 'Annual 2026/Class 1', 'Mid Term/Class 1']);
      expect((await repo.getExams(classId: class1)).length, 2);
      expect((await repo.getExams(query: 'mid')).single.name, 'Mid Term');
      expect(all.first.date, DateTime(2026, 5, 2));
    });

    test('refuses empty name, no class and a repeated name in the same class', () async {
      await repo.saveExam(Exam(name: 'Annual', classId: class1));

      expect(() => repo.saveExam(Exam(name: ' ', classId: class1)), throwsA(isA<ExamsException>()));
      expect(() => repo.saveExam(const Exam(name: 'X', classId: 0)), throwsA(isA<ExamsException>()));
      expect(() => repo.saveExam(Exam(name: 'annual', classId: class1)), throwsA(isA<ExamsException>()));
    });

    test('rename and move class are allowed while there are no marks', () async {
      await repo.saveExam(Exam(name: 'Annual', classId: class1));
      final id = await examId('Annual');

      await repo.saveExam(Exam(id: id, name: 'Annual 2026', classId: class2));

      final e = (await repo.getExams()).single;
      expect((e.name, e.classId), ('Annual 2026', class2));
    });

    test('delete works when empty', () async {
      await repo.saveExam(Exam(name: 'Annual', classId: class1));
      await repo.deleteExam(await examId('Annual'));

      expect(await repo.getExams(), isEmpty);
    });
  });

  group('marks sheet and marks', () {
    late int exam;
    late int english;
    late int math;

    setUp(() async {
      await repo.saveSubject(Subject(classId: class1, name: 'English'));
      await repo.saveSubject(Subject(classId: class1, name: 'Math', totalMarks: 50));
      final subjects = await subjectsOf(class1);
      english = subjects[0].id;
      math = subjects[1].id;
      await repo.saveExam(Exam(name: 'Annual', classId: class1));
      exam = await examId('Annual');
    });

    test('sheet lists active students of the class with section, subjects and no marks', () async {
      final sheet = await repo.getMarksSheet(exam);

      expect(sheet.exam.className, 'Class 1');
      expect(sheet.subjects.map((s) => s.name), ['English', 'Math']);
      expect(sheet.students.map((s) => s.name), ['Ali', 'Sara', 'Zain']);
      expect(sheet.students.first.sectionName, 'A');
      expect(sheet.students.every((s) => s.marks.isEmpty), isTrue);
    });

    test('saved marks come back; saving again changes them, no duplicate rows', () async {
      await repo.saveMarks(exam, [
        MarkEntry(studentId: ali, subjectId: english, marks: 80),
        MarkEntry(studentId: ali, subjectId: math, marks: 40),
        MarkEntry(studentId: sara, subjectId: english, marks: 55),
      ]);
      await repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: english, marks: 90)]);

      final sheet = await repo.getMarksSheet(exam);
      expect(sheet.students[0].marks, {english: 90, math: 40});
      expect(sheet.students[1].marks, {english: 55});
      expect(sheet.exam.studentsWithMarks, 2);
      expect(await db.select(db.results).get(), hasLength(3));
    });

    test('a null mark clears it', () async {
      await repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: english, marks: 80)]);
      await repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: english)]);

      expect((await repo.getMarksSheet(exam)).students.first.marks, isEmpty);
      expect(await db.select(db.results).get(), isEmpty);
    });

    test('marks above the subject total or below 0 refuse the whole save', () async {
      expect(
        () => repo.saveMarks(exam, [
          MarkEntry(studentId: ali, subjectId: english, marks: 70),
          MarkEntry(studentId: ali, subjectId: math, marks: 51),
        ]),
        throwsA(isA<ExamsException>()),
      );
      expect(() => repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: english, marks: -1)]),
          throwsA(isA<ExamsException>()));

      expect(await db.select(db.results).get(), isEmpty, reason: 'nothing saved');
    });

    test('a subject of another class is refused', () async {
      await repo.saveSubject(Subject(classId: class2, name: 'Drawing'));
      final other = (await subjectsOf(class2)).single.id;

      expect(() => repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: other, marks: 5)]),
          throwsA(isA<ExamsException>()));
    });

    test('students who left but have marks stay on the sheet', () async {
      await repo.saveMarks(exam, [MarkEntry(studentId: zain, subjectId: english, marks: 70)]);
      await (db.update(db.students)..where((t) => t.id.equals(zain)))
          .write(const StudentsCompanion(status: Value('left')));

      expect((await repo.getMarksSheet(exam)).students.map((s) => s.name), ['Ali', 'Sara', 'Zain']);
    });

    test('delete exam, delete subject and shrinking a subject are blocked once marks exist', () async {
      await repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: math, marks: 45)]);

      expect(() => repo.deleteExam(exam), throwsA(isA<ExamsException>()));
      expect(() => repo.deleteSubject(math), throwsA(isA<ExamsException>()));
      expect(() => repo.saveSubject(Subject(id: math, classId: class1, name: 'Math', totalMarks: 40)),
          throwsA(isA<ExamsException>()));
      await repo.saveSubject(Subject(id: math, classId: class1, name: 'Math', totalMarks: 60));
      await repo.deleteSubject(english);
      expect((await subjectsOf(class1)).map((s) => s.name), ['Math']);
    });

    test('the class of an exam cannot change after marks', () async {
      await repo.saveMarks(exam, [MarkEntry(studentId: ali, subjectId: math, marks: 45)]);

      expect(() => repo.saveExam(Exam(id: exam, name: 'Annual', classId: class2)),
          throwsA(isA<ExamsException>()));
      await repo.saveExam(Exam(id: exam, name: 'Annual 2026', classId: class1));
    });

    test('sheet results work with the calculator end to end', () async {
      await repo.saveMarks(exam, [
        MarkEntry(studentId: ali, subjectId: english, marks: 90),
        MarkEntry(studentId: ali, subjectId: math, marks: 45),
        MarkEntry(studentId: sara, subjectId: english, marks: 60),
        MarkEntry(studentId: sara, subjectId: math, marks: 30),
        MarkEntry(studentId: zain, subjectId: english, marks: 20),
      ]);
      final sheet = await repo.getMarksSheet(exam);

      final results = ResultCalculator.compute(sheet.subjects, sheet.students);

      expect(results.map((r) => (r.student.name, r.position, r.status)), [
        ('Ali', 1, ResultStatus.pass),
        ('Sara', 2, ResultStatus.pass),
        ('Zain', null, ResultStatus.incomplete),
      ]);
      expect(results.first.percent, 90.0);

      final card = ResultCard.from(
        school: await repo.getSchoolInfo(),
        sheet: sheet,
        result: results.first,
        all: results,
      );
      expect(card.classLabel, 'Class 1 - A');
      expect(card.rankedStudents, 2);
      expect(card.lines.map((l) => (l.name, l.obtained, l.grade)), [('English', 90, 'A+'), ('Math', 45, 'A+')]);
    });
  });

  test('student history lists every exam, newest first, with position', () async {
    await repo.saveSubject(Subject(classId: class1, name: 'English'));
    final english = (await subjectsOf(class1)).single.id;
    await repo.saveExam(Exam(name: 'Mid Term', classId: class1, date: DateTime(2026, 3, 1)));
    await repo.saveExam(Exam(name: 'Annual', classId: class1, date: DateTime(2026, 5, 1)));
    await repo.saveMarks(await examId('Mid Term'), [
      MarkEntry(studentId: ali, subjectId: english, marks: 50),
      MarkEntry(studentId: sara, subjectId: english, marks: 70),
    ]);
    await repo.saveMarks(await examId('Annual'), [
      MarkEntry(studentId: ali, subjectId: english, marks: 85),
      MarkEntry(studentId: sara, subjectId: english, marks: 40),
    ]);

    final history = await repo.getStudentHistory(ali);

    expect(history.map((h) => (h.examName, h.obtained, h.grade, h.position)), [
      ('Annual', 85, 'A+', 1),
      ('Mid Term', 50, 'C', 2),
    ]);
    expect(await repo.getStudentHistory(zain), isEmpty);
  });

  test('school info comes from settings, with defaults', () async {
    expect((await repo.getSchoolInfo()).name, 'Rozatul Atfal');

    await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
          key: AppConstants.settingSchoolName,
          value: 'Test School',
        ));
    expect((await repo.getSchoolInfo()).name, 'Test School');
  });

  test('class options list classes with sections', () async {
    final options = await repo.getClassOptions();

    expect(options.map((c) => c.name), ['Class 1', 'Class 2']);
    expect(options.first.sections.single.name, 'A');
  });
}
