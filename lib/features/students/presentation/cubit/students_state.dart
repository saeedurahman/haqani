import 'package:equatable/equatable.dart';

import '../../domain/student.dart';
import '../../domain/student_extras.dart';

enum StudentsStatus { initial, loading, success, failure }

class StudentsState extends Equatable {
  const StudentsState({
    this.status = StudentsStatus.initial,
    this.students = const [],
    this.classes = const [],
    this.query = '',
    this.classFilter,
    this.includeLeft = false,
    this.errorMessage,
  });

  final StudentsStatus status;
  final List<Student> students;
  final List<ClassOption> classes;
  final String query;

  /// Null means all classes.
  final int? classFilter;
  final bool includeLeft;
  final String? errorMessage;

  bool get hasFilter => query.trim().isNotEmpty || classFilter != null;

  StudentsState copyWith({
    StudentsStatus? status,
    List<Student>? students,
    List<ClassOption>? classes,
    String? query,
    int? Function()? classFilter,
    bool? includeLeft,
    String? errorMessage,
  }) {
    return StudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      classes: classes ?? this.classes,
      query: query ?? this.query,
      classFilter: classFilter == null ? this.classFilter : classFilter(),
      includeLeft: includeLeft ?? this.includeLeft,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, students, classes, query, classFilter, includeLeft, errorMessage];
}
