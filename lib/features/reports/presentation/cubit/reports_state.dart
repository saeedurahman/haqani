import 'package:equatable/equatable.dart';

import '../../../exams/domain/exam_models.dart';
import '../../../students/domain/student.dart';
import '../../../students/domain/student_extras.dart';
import '../../domain/report_kind.dart';
import '../../domain/report_models.dart';

enum ReportsStatus { initial, loading, success, failure }

class ReportsState extends Equatable {
  const ReportsState({
    required this.kind,
    this.status = ReportsStatus.initial,
    this.classes = const [],
    this.exams = const [],
    this.studentMatches = const [],
    this.classId,
    this.sectionId,
    required this.month,
    this.from,
    this.to,
    this.feeStatus,
    this.examId,
    this.student,
    this.search = '',
    this.document,
    this.errorMessage,
  });

  final ReportKind kind;
  final ReportsStatus status;
  final List<ClassOption> classes;
  final List<Exam> exams;

  /// Students found by the search box of the student history report.
  final List<Student> studentMatches;

  /// Null means all classes (fee reports) or nothing chosen yet.
  final int? classId;
  final int? sectionId;

  /// First day of the chosen month.
  final DateTime month;
  final DateTime? from;
  final DateTime? to;

  /// `paid`, `partial`, `unpaid` or null for all.
  final String? feeStatus;
  final int? examId;
  final Student? student;

  /// Text typed in the table search box.
  final String search;

  /// The report as built from the database, without the search applied.
  final ReportDocument? document;
  final String? errorMessage;

  ClassOption? get selectedClass =>
      classes.where((c) => c.id == classId).firstOrNull;

  /// The report with the search applied. This is also what gets exported.
  ReportDocument? get visibleDocument => document?.filtered(search);

  /// True when the report needs a choice (exam or student) that is not made yet.
  bool get needsChoice =>
      (kind == ReportKind.examResults && examId == null) ||
      (kind == ReportKind.studentHistory && student == null);

  ReportsState copyWith({
    ReportsStatus? status,
    List<ClassOption>? classes,
    List<Exam>? exams,
    List<Student>? studentMatches,
    int? Function()? classId,
    int? Function()? sectionId,
    DateTime? month,
    DateTime? Function()? from,
    DateTime? Function()? to,
    String? Function()? feeStatus,
    int? Function()? examId,
    Student? Function()? student,
    String? search,
    ReportDocument? Function()? document,
    String? errorMessage,
  }) {
    return ReportsState(
      kind: kind,
      status: status ?? this.status,
      classes: classes ?? this.classes,
      exams: exams ?? this.exams,
      studentMatches: studentMatches ?? this.studentMatches,
      classId: classId == null ? this.classId : classId(),
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      month: month ?? this.month,
      from: from == null ? this.from : from(),
      to: to == null ? this.to : to(),
      feeStatus: feeStatus == null ? this.feeStatus : feeStatus(),
      examId: examId == null ? this.examId : examId(),
      student: student == null ? this.student : student(),
      search: search ?? this.search,
      document: document == null ? this.document : document(),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    kind,
    status,
    classes,
    exams,
    studentMatches,
    classId,
    sectionId,
    month,
    from,
    to,
    feeStatus,
    examId,
    student,
    search,
    document,
    errorMessage,
  ];
}
