import 'package:equatable/equatable.dart';

import 'exam_models.dart';

/// Grades and pass mark. Percent is 0 to 100.
class GradeScale {
  const GradeScale._();

  /// Pass mark in percent, for the total and for every subject.
  static const passPercent = 33.0;

  static String gradeOf(double percent) {
    if (percent >= 80) return 'A+';
    if (percent >= 70) return 'A';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    if (percent >= 40) return 'D';
    if (percent >= passPercent) return 'E';
    return 'F';
  }
}

enum ResultStatus {
  /// No marks entered yet.
  notEntered,

  /// Some subjects have no marks yet.
  incomplete,
  pass,
  fail;

  String get label => switch (this) {
        notEntered => 'No marks',
        incomplete => 'Incomplete',
        pass => 'Pass',
        fail => 'Fail',
      };
}

/// Total, percent, grade and position of one student in one exam.
class StudentResult extends Equatable {
  const StudentResult({
    required this.student,
    required this.obtained,
    required this.maxMarks,
    required this.percent,
    required this.grade,
    required this.status,
    this.position,
  });

  final StudentMarks student;
  final int obtained;
  final int maxMarks;
  final double percent;
  final String grade;
  final ResultStatus status;

  /// 1 = first. Null until every subject has marks. Equal totals share a position.
  final int? position;

  bool get isComplete => status == ResultStatus.pass || status == ResultStatus.fail;

  @override
  List<Object?> get props => [student, obtained, maxMarks, percent, grade, status, position];
}

class ResultCalculator {
  const ResultCalculator._();

  /// Results in the same order as [students]. Absent subjects count as 0 in
  /// the total, so a student cannot gain by missing a paper.
  static List<StudentResult> compute(List<Subject> subjects, List<StudentMarks> students) {
    final maxMarks = subjects.fold<int>(0, (sum, s) => sum + s.totalMarks);

    final drafts = <StudentResult>[];
    for (final student in students) {
      final entered = [for (final s in subjects) if (student.marks.containsKey(s.id)) s];
      final obtained = entered.fold<int>(0, (sum, s) => sum + student.marks[s.id]!);
      final percent = maxMarks == 0 ? 0.0 : obtained * 100 / maxMarks;

      final ResultStatus status;
      if (entered.isEmpty) {
        status = ResultStatus.notEntered;
      } else if (entered.length < subjects.length) {
        status = ResultStatus.incomplete;
      } else {
        final everySubjectPassed = subjects.every((s) {
          final marks = student.marks[s.id]!;
          return s.totalMarks == 0 || marks * 100 / s.totalMarks >= GradeScale.passPercent;
        });
        status = everySubjectPassed && percent >= GradeScale.passPercent
            ? ResultStatus.pass
            : ResultStatus.fail;
      }

      drafts.add(StudentResult(
        student: student,
        obtained: obtained,
        maxMarks: maxMarks,
        percent: percent,
        grade: status == ResultStatus.notEntered ? '-' : GradeScale.gradeOf(percent),
        status: status,
      ));
    }

    // Positions: highest total first, equal totals share a position (1, 1, 3).
    final ranked = drafts.where((r) => r.isComplete).toList()
      ..sort((a, b) => b.obtained.compareTo(a.obtained));
    final positions = <int, int>{};
    for (var i = 0; i < ranked.length; i++) {
      final sameAsBefore = i > 0 && ranked[i].obtained == ranked[i - 1].obtained;
      positions[ranked[i].student.studentId] =
          sameAsBefore ? positions[ranked[i - 1].student.studentId]! : i + 1;
    }

    return [
      for (final r in drafts)
        StudentResult(
          student: r.student,
          obtained: r.obtained,
          maxMarks: r.maxMarks,
          percent: r.percent,
          grade: r.grade,
          status: r.status,
          position: positions[r.student.studentId],
        ),
    ];
  }
}
