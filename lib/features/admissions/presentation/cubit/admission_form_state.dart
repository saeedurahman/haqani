import 'package:equatable/equatable.dart';

import '../../../students/domain/student.dart';
import '../../../students/domain/student_extras.dart';

enum AdmissionFormStatus { initial, loading, ready, saving, saved, failure }

class AdmissionFormState extends Equatable {
  const AdmissionFormState({
    this.status = AdmissionFormStatus.initial,
    this.classes = const [],
    this.nextAdmissionNo = '',
    this.admitted,
    this.errorMessage,
  });

  final AdmissionFormStatus status;
  final List<ClassOption> classes;

  /// Shown to the user before saving. The final number is given at save time.
  final String nextAdmissionNo;

  /// The student that was just saved.
  final Student? admitted;
  final String? errorMessage;

  AdmissionFormState copyWith({
    AdmissionFormStatus? status,
    List<ClassOption>? classes,
    String? nextAdmissionNo,
    Student? admitted,
    String? errorMessage,
  }) {
    return AdmissionFormState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      nextAdmissionNo: nextAdmissionNo ?? this.nextAdmissionNo,
      admitted: admitted ?? this.admitted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, classes, nextAdmissionNo, admitted, errorMessage];
}
