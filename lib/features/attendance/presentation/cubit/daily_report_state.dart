import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/attendance_models.dart';

enum DailyReportStatus { initial, loading, success, failure }

class DailyReportState extends Equatable {
  const DailyReportState({
    this.status = DailyReportStatus.initial,
    this.classes = const [],
    this.classId,
    this.sectionId,
    required this.date,
    this.entries = const [],
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final DailyReportStatus status;
  final List<ClassOption> classes;
  final int? classId;
  final int? sectionId;
  final DateTime date;
  final List<AttendanceEntry> entries;
  final String? errorMessage;

  /// One-time message after Send on WhatsApp. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ClassOption? get selectedClass => classes.where((c) => c.id == classId).firstOrNull;

  int count(String? status) => entries.where((e) => e.status == status).length;

  DailyReportState copyWith({
    DailyReportStatus? status,
    List<ClassOption>? classes,
    int? Function()? classId,
    int? Function()? sectionId,
    DateTime? date,
    List<AttendanceEntry>? entries,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return DailyReportState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      classId: classId == null ? this.classId : classId(),
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      date: date ?? this.date,
      entries: entries ?? this.entries,
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
        date,
        entries,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
