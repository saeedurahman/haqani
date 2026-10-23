import 'package:equatable/equatable.dart';

import '../../domain/exam_models.dart';
import '../../domain/result_calculator.dart';

enum MarksStatus { initial, loading, success, failure }

/// Identifies one box in the marks grid.
typedef MarkKey = (int studentId, int subjectId);

class MarksState extends Equatable {
  const MarksState({
    this.status = MarksStatus.initial,
    this.sheet,
    this.edits = const {},
    this.isSaving = false,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final MarksStatus status;

  /// What is saved in the database.
  final MarksSheet? sheet;

  /// Changes typed but not saved. A null value means the box was emptied.
  final Map<MarkKey, int?> edits;
  final bool isSaving;
  final String? errorMessage;
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  bool get hasChanges => edits.isNotEmpty;

  /// Marks of a student with the unsaved changes applied.
  Map<int, int> marksOf(StudentMarks student) {
    final marks = Map<int, int>.of(student.marks);
    edits.forEach((key, value) {
      if (key.$1 != student.studentId) return;
      if (value == null) {
        marks.remove(key.$2);
      } else {
        marks[key.$2] = value;
      }
    });
    return marks;
  }

  /// Results of the saved marks.
  List<StudentResult> get savedResults => sheet == null
      ? const []
      : ResultCalculator.compute(sheet!.subjects, sheet!.students);

  /// Results while typing, with unsaved changes included.
  List<StudentResult> get liveResults {
    final s = sheet;
    if (s == null) return const [];
    return ResultCalculator.compute(s.subjects, [
      for (final student in s.students)
        StudentMarks(
          studentId: student.studentId,
          name: student.name,
          admissionNo: student.admissionNo,
          fatherName: student.fatherName,
          gender: student.gender,
          sectionName: student.sectionName,
          marks: marksOf(student),
        ),
    ]);
  }

  /// True if a typed mark is above the subject total.
  bool isInvalid(MarkKey key) {
    final value = edits[key];
    if (value == null || sheet == null) return false;
    final subject = sheet!.subjects.where((s) => s.id == key.$2).firstOrNull;
    return subject != null && value > subject.totalMarks;
  }

  bool get hasInvalid => edits.keys.any(isInvalid);

  MarksState copyWith({
    MarksStatus? status,
    MarksSheet? sheet,
    Map<MarkKey, int?>? edits,
    bool? isSaving,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return MarksState(
      status: status ?? this.status,
      sheet: sheet ?? this.sheet,
      edits: edits ?? this.edits,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sheet,
        edits,
        isSaving,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
