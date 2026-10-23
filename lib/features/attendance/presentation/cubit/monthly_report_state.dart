import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/attendance_models.dart';

enum MonthlyReportStatus { initial, loading, success, failure }

class MonthlyReportState extends Equatable {
  const MonthlyReportState({
    this.status = MonthlyReportStatus.initial,
    this.classes = const [],
    this.classId,
    this.sectionId,
    required this.month,
    this.rows = const [],
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final MonthlyReportStatus status;
  final List<ClassOption> classes;
  final int? classId;
  final int? sectionId;

  /// First day of the chosen month.
  final DateTime month;
  final List<MonthlyAttendanceRow> rows;
  final String? errorMessage;

  /// One-time message after Send on WhatsApp. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ClassOption? get selectedClass => classes.where((c) => c.id == classId).firstOrNull;

  MonthlyReportState copyWith({
    MonthlyReportStatus? status,
    List<ClassOption>? classes,
    int? Function()? classId,
    int? Function()? sectionId,
    DateTime? month,
    List<MonthlyAttendanceRow>? rows,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return MonthlyReportState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      classId: classId == null ? this.classId : classId(),
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      month: month ?? this.month,
      rows: rows ?? this.rows,
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
        sectionId,
        month,
        rows,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
