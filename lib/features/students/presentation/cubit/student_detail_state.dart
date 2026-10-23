import 'package:equatable/equatable.dart';

import '../../domain/student.dart';
import '../../domain/student_extras.dart';
import '../../domain/student_history.dart';

enum StudentDetailStatus { initial, loading, success, failure }

class StudentDetailState extends Equatable {
  const StudentDetailState({
    this.status = StudentDetailStatus.initial,
    this.student,
    this.documents = const [],
    this.history = const StudentHistory(),
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final StudentDetailStatus status;
  final Student? student;
  final List<StudentDocumentItem> documents;
  final StudentHistory history;
  final String? errorMessage;

  /// One-time message after an action. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  StudentDetailState copyWith({
    StudentDetailStatus? status,
    Student? student,
    List<StudentDocumentItem>? documents,
    StudentHistory? history,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return StudentDetailState(
      status: status ?? this.status,
      student: student ?? this.student,
      documents: documents ?? this.documents,
      history: history ?? this.history,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        student,
        documents,
        history,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
