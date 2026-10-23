import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/exams/domain/result_calculator.dart';

void main() {
  const english = Subject(id: 1, classId: 1, name: 'English', totalMarks: 100);
  const math = Subject(id: 2, classId: 1, name: 'Math', totalMarks: 100);
  const urdu = Subject(id: 3, classId: 1, name: 'Urdu', totalMarks: 50);
  const subjects = [english, math, urdu];

  StudentMarks student(int id, Map<int, int> marks) =>
      StudentMarks(studentId: id, name: 'S$id', admissionNo: '$id', marks: marks);

  group('GradeScale', () {
    test('grade bands', () {
      expect(GradeScale.gradeOf(100), 'A+');
      expect(GradeScale.gradeOf(80), 'A+');
      expect(GradeScale.gradeOf(79.9), 'A');
      expect(GradeScale.gradeOf(70), 'A');
      expect(GradeScale.gradeOf(60), 'B');
      expect(GradeScale.gradeOf(50), 'C');
      expect(GradeScale.gradeOf(40), 'D');
      expect(GradeScale.gradeOf(33), 'E');
      expect(GradeScale.gradeOf(32.9), 'F');
      expect(GradeScale.gradeOf(0), 'F');
    });
  });

  group('ResultCalculator', () {
    test('total, max, percent and grade', () {
      final r = ResultCalculator.compute(subjects, [
        student(1, {1: 90, 2: 80, 3: 40}),
      ]).single;

      expect(r.obtained, 210);
      expect(r.maxMarks, 250);
      expect(r.percent, closeTo(84.0, 0.001));
      expect(r.grade, 'A+');
      expect(r.status, ResultStatus.pass);
      expect(r.position, 1);
    });

    test('positions: highest first, ties share a position and skip the next', () {
      final results = ResultCalculator.compute(subjects, [
        student(1, {1: 70, 2: 70, 3: 40}),
        student(2, {1: 90, 2: 90, 3: 45}),
        student(3, {1: 70, 2: 70, 3: 40}),
        student(4, {1: 50, 2: 50, 3: 25}),
      ]);

      expect(results.map((r) => r.position), [2, 1, 2, 4]);
    });

    test('results keep the order of the students given', () {
      final results = ResultCalculator.compute(subjects, [
        student(5, {1: 10, 2: 10, 3: 10}),
        student(3, {1: 90, 2: 90, 3: 45}),
      ]);

      expect(results.map((r) => r.student.studentId), [5, 3]);
    });

    test('a failed subject fails the student even with a high total', () {
      final r = ResultCalculator.compute(subjects, [
        student(1, {1: 100, 2: 20, 3: 50}),
      ]).single;

      expect(r.percent, closeTo(68.0, 0.001));
      expect(r.status, ResultStatus.fail);
      expect(r.grade, 'B', reason: 'grade follows the total percent');
    });

    test('exactly the pass mark passes', () {
      final r = ResultCalculator.compute(
        const [Subject(id: 1, classId: 1, name: 'A', totalMarks: 100)],
        [student(1, {1: 33})],
      ).single;

      expect(r.status, ResultStatus.pass);
      expect(r.grade, 'E');
    });

    test('a student with only some subjects is incomplete and not ranked', () {
      final results = ResultCalculator.compute(subjects, [
        student(1, {1: 90, 2: 90, 3: 45}),
        student(2, {1: 100}),
      ]);

      expect(results[1].status, ResultStatus.incomplete);
      expect(results[1].position, isNull);
      expect(results[1].obtained, 100);
      expect(results[1].maxMarks, 250, reason: 'the total is out of every subject');
      expect(results[0].position, 1);
    });

    test('a student with no marks has no grade and no position', () {
      final r = ResultCalculator.compute(subjects, [student(1, {})]).single;

      expect(r.status, ResultStatus.notEntered);
      expect(r.grade, '-');
      expect(r.position, isNull);
      expect(r.obtained, 0);
    });

    test('a class without subjects does not crash', () {
      final r = ResultCalculator.compute(const [], [student(1, {})]).single;

      expect(r.maxMarks, 0);
      expect(r.percent, 0);
      expect(r.status, ResultStatus.notEntered);
    });

    test('marks of a deleted subject are ignored', () {
      final r = ResultCalculator.compute(const [english], [
        student(1, {1: 60, 99: 40}),
      ]).single;

      expect(r.obtained, 60);
      expect(r.status, ResultStatus.pass);
    });

    test('empty class', () {
      expect(ResultCalculator.compute(subjects, const []), isEmpty);
    });
  });
}
