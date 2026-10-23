import 'package:equatable/equatable.dart';

import 'exam_models.dart';
import 'result_calculator.dart';

/// One subject on a result card.
class SubjectLine extends Equatable {
  const SubjectLine({
    required this.name,
    required this.totalMarks,
    this.obtained,
    required this.grade,
  });

  final String name;
  final int totalMarks;

  /// Null when no marks were entered.
  final int? obtained;
  final String grade;

  @override
  List<Object?> get props => [name, totalMarks, obtained, grade];
}

/// Everything printed on one student's result card.
class ResultCard extends Equatable {
  const ResultCard({
    required this.school,
    required this.exam,
    required this.classLabel,
    required this.result,
    required this.lines,
    required this.rankedStudents,
  });

  final SchoolInfo school;
  final Exam exam;

  /// Example: "Class 1 - A".
  final String classLabel;
  final StudentResult result;
  final List<SubjectLine> lines;

  /// How many students have a position in this exam.
  final int rankedStudents;

  /// Builds the card of [result] from the exam sheet.
  factory ResultCard.from({
    required SchoolInfo school,
    required MarksSheet sheet,
    required StudentResult result,
    required List<StudentResult> all,
  }) {
    final section = result.student.sectionName;
    return ResultCard(
      school: school,
      exam: sheet.exam,
      classLabel: section == null ? sheet.exam.className : '${sheet.exam.className} - $section',
      result: result,
      lines: [
        for (final s in sheet.subjects)
          SubjectLine(
            name: s.name,
            totalMarks: s.totalMarks,
            obtained: result.student.marks[s.id],
            grade: result.student.marks[s.id] == null || s.totalMarks == 0
                ? '-'
                : GradeScale.gradeOf(result.student.marks[s.id]! * 100 / s.totalMarks),
          ),
      ],
      rankedStudents: all.where((r) => r.position != null).length,
    );
  }

  @override
  List<Object?> get props => [school, exam, classLabel, result, lines, rankedStudents];
}

/// One line of a student's previous results.
class ExamSummary extends Equatable {
  const ExamSummary({
    required this.examName,
    this.examDate,
    required this.className,
    required this.obtained,
    required this.maxMarks,
    required this.percent,
    required this.grade,
    required this.status,
    this.position,
  });

  final String examName;
  final DateTime? examDate;
  final String className;
  final int obtained;
  final int maxMarks;
  final double percent;
  final String grade;
  final ResultStatus status;
  final int? position;

  @override
  List<Object?> get props =>
      [examName, examDate, className, obtained, maxMarks, percent, grade, status, position];
}
