import 'package:equatable/equatable.dart';

import '../../domain/school_class.dart';

enum ClassesStatus { initial, loading, success, failure }

class ClassesState extends Equatable {
  const ClassesState({
    this.status = ClassesStatus.initial,
    this.classes = const [],
    this.teachers = const [],
    this.query = '',
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final ClassesStatus status;
  final List<SchoolClass> classes;
  final List<TeacherOption> teachers;
  final String query;

  /// Set when the list could not be loaded.
  final String? errorMessage;

  /// One-time message after add / edit / delete. [feedbackId] changes every
  /// time, so the same text can show again.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  /// Classes matching the search text (class name or section name).
  List<SchoolClass> get visibleClasses {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return classes;
    return classes
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.sections.any((s) => s.name.toLowerCase().contains(q)),
        )
        .toList();
  }

  ClassesState copyWith({
    ClassesStatus? status,
    List<SchoolClass>? classes,
    List<TeacherOption>? teachers,
    String? query,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return ClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      teachers: teachers ?? this.teachers,
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
    teachers,
    query,
    errorMessage,
    feedback,
    feedbackIsError,
    feedbackId,
  ];
}
