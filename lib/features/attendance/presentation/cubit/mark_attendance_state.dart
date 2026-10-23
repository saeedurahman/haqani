import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/attendance_models.dart';

enum MarkAttendanceStatus { initial, loading, success, failure }

class MarkAttendanceState extends Equatable {
  const MarkAttendanceState({
    this.status = MarkAttendanceStatus.initial,
    this.classes = const [],
    this.classId,
    this.sectionId,
    required this.date,
    this.entries = const [],
    this.savedEntries = const [],
    this.alreadyMarked = false,
    this.isSaving = false,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final MarkAttendanceStatus status;
  final List<ClassOption> classes;
  final int? classId;
  final int? sectionId;
  final DateTime date;

  /// What is on screen. Students without a saved status start as present.
  final List<AttendanceEntry> entries;

  /// What was last loaded or saved, to know if anything changed.
  final List<AttendanceEntry> savedEntries;

  /// True if this class already has attendance saved for [date].
  final bool alreadyMarked;
  final bool isSaving;
  final String? errorMessage;

  /// One-time message after Save. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ClassOption? get selectedClass => classes.where((c) => c.id == classId).firstOrNull;

  bool get hasChanges => !_sameStatuses;

  bool get _sameStatuses {
    if (entries.length != savedEntries.length) return false;
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].status != savedEntries[i].status) return false;
    }
    return true;
  }

  int count(String status) => entries.where((e) => e.status == status).length;

  MarkAttendanceState copyWith({
    MarkAttendanceStatus? status,
    List<ClassOption>? classes,
    int? Function()? classId,
    int? Function()? sectionId,
    DateTime? date,
    List<AttendanceEntry>? entries,
    List<AttendanceEntry>? savedEntries,
    bool? alreadyMarked,
    bool? isSaving,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return MarkAttendanceState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      classId: classId == null ? this.classId : classId(),
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      date: date ?? this.date,
      entries: entries ?? this.entries,
      savedEntries: savedEntries ?? this.savedEntries,
      alreadyMarked: alreadyMarked ?? this.alreadyMarked,
      isSaving: isSaving ?? this.isSaving,
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
        savedEntries,
        alreadyMarked,
        isSaving,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
