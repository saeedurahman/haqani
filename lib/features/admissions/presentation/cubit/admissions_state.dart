import 'package:equatable/equatable.dart';

import '../../../students/domain/student.dart';

enum AdmissionsStatus { initial, loading, success, failure }

class AdmissionsState extends Equatable {
  const AdmissionsState({
    this.status = AdmissionsStatus.initial,
    this.students = const [],
    this.query = '',
    this.from,
    this.to,
    this.errorMessage,
  });

  final AdmissionsStatus status;
  final List<Student> students;
  final String query;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;

  bool get hasFilter => query.trim().isNotEmpty || from != null || to != null;

  AdmissionsState copyWith({
    AdmissionsStatus? status,
    List<Student>? students,
    String? query,
    DateTime? Function()? from,
    DateTime? Function()? to,
    String? errorMessage,
  }) {
    return AdmissionsState(
      status: status ?? this.status,
      students: students ?? this.students,
      query: query ?? this.query,
      from: from == null ? this.from : from(),
      to: to == null ? this.to : to(),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, students, query, from, to, errorMessage];
}
