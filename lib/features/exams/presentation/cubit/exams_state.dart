import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/exam_models.dart';

enum ExamsStatus { initial, loading, success, failure }

class ExamsState extends Equatable {
  const ExamsState({
    this.status = ExamsStatus.initial,
    this.classes = const [],
    this.exams = const [],
    this.classFilter,
    this.query = '',
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final ExamsStatus status;
  final List<ClassOption> classes;
  final List<Exam> exams;

  /// Null means all classes.
  final int? classFilter;
  final String query;
  final String? errorMessage;

  /// One-time message after add / edit / delete. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  bool get hasFilter => classFilter != null || query.trim().isNotEmpty;

  ExamsState copyWith({
    ExamsStatus? status,
    List<ClassOption>? classes,
    List<Exam>? exams,
    int? Function()? classFilter,
    String? query,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return ExamsState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      exams: exams ?? this.exams,
      classFilter: classFilter == null ? this.classFilter : classFilter(),
      query: query ?? this.query,
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
        exams,
        classFilter,
        query,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
