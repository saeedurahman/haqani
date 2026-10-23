import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/exam_models.dart';

enum SubjectsStatus { initial, loading, success, failure }

class SubjectsState extends Equatable {
  const SubjectsState({
    this.status = SubjectsStatus.initial,
    this.classes = const [],
    this.classId,
    this.subjects = const [],
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final SubjectsStatus status;
  final List<ClassOption> classes;
  final int? classId;
  final List<Subject> subjects;
  final String? errorMessage;
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  int get totalMarks => subjects.fold(0, (sum, s) => sum + s.totalMarks);

  SubjectsState copyWith({
    SubjectsStatus? status,
    List<ClassOption>? classes,
    int? Function()? classId,
    List<Subject>? subjects,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return SubjectsState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      classId: classId == null ? this.classId : classId(),
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        classes,
        classId,
        subjects,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
