import 'package:equatable/equatable.dart';

import '../../domain/student.dart';
import '../../domain/student_extras.dart';

enum StudentFormStatus { initial, loading, ready, saving, saved, failure }

class StudentFormState extends Equatable {
  const StudentFormState({
    this.status = StudentFormStatus.initial,
    this.student,
    this.classes = const [],
    this.suggestedAdmissionNo = '',
    this.savedId,
    this.errorMessage,
  });

  final StudentFormStatus status;

  /// The student being edited. Null when adding a new one.
  final Student? student;
  final List<ClassOption> classes;
  final String suggestedAdmissionNo;
  final int? savedId;

  /// Load error, or the reason a save was refused.
  final String? errorMessage;

  bool get isEditing => student != null;

  StudentFormState copyWith({
    StudentFormStatus? status,
    Student? student,
    List<ClassOption>? classes,
    String? suggestedAdmissionNo,
    int? savedId,
    String? errorMessage,
  }) {
    return StudentFormState(
      status: status ?? this.status,
      student: student ?? this.student,
      classes: classes ?? this.classes,
      suggestedAdmissionNo: suggestedAdmissionNo ?? this.suggestedAdmissionNo,
      savedId: savedId ?? this.savedId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, student, classes, suggestedAdmissionNo, savedId, errorMessage];
}
