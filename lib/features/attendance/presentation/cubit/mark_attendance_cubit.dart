import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/whatsapp_messages.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_repository.dart';
import 'mark_attendance_state.dart';

class MarkAttendanceCubit extends Cubit<MarkAttendanceState> {
  MarkAttendanceCubit(this._repository, this._whatsApp, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(MarkAttendanceState(date: _dateOnly((clock ?? DateTime.now)())));

  final AttendanceRepository _repository;
  final WhatsAppService _whatsApp;
  final DateTime Function() _clock;

  /// Only the newest sheet may update the screen.
  int _request = 0;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> load() async {
    emit(state.copyWith(status: MarkAttendanceStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(
        classes: classes,
        classId: () => classes.isEmpty ? null : classes.first.id,
        sectionId: () => null,
      ));
      await _loadSheet();
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectClass(int? classId) {
    emit(state.copyWith(classId: () => classId, sectionId: () => null));
    return _loadSheet();
  }

  Future<void> selectSection(int? sectionId) {
    emit(state.copyWith(sectionId: () => sectionId));
    return _loadSheet();
  }

  /// Dates after today are not allowed.
  Future<void> selectDate(DateTime date) {
    final today = _dateOnly(_clock());
    final day = _dateOnly(date);
    emit(state.copyWith(date: day.isAfter(today) ? today : day));
    return _loadSheet();
  }

  void setStatus(int studentId, String status) {
    emit(state.copyWith(entries: [
      for (final e in state.entries) e.studentId == studentId ? e.withStatus(status) : e,
    ]));
  }

  void markAll(String status) {
    emit(state.copyWith(entries: [for (final e in state.entries) e.withStatus(status)]));
  }

  /// Opens WhatsApp to tell the parent that the student was absent on this date.
  Future<void> sendAbsent(int studentId) async {
    final entry = state.entries.where((e) => e.studentId == studentId).firstOrNull;
    if (entry == null) return;
    final result = await _whatsApp.sendToParent(
      studentId: studentId,
      body: WhatsAppMessages.absent(studentName: entry.name, date: state.date),
    );
    emit(state.copyWith(
      feedback: result.userMessage,
      feedbackIsError: result.isError,
      feedbackId: state.feedbackId + 1,
    ));
  }

  Future<void> save() async {
    if (state.isSaving || state.entries.isEmpty) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.saveDailySheet(state.date, state.entries);
      emit(state.copyWith(
        isSaving: false,
        savedEntries: state.entries,
        alreadyMarked: true,
        feedback: 'Attendance saved.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        feedback: AppStrings.somethingWentWrong,
        feedbackIsError: true,
        feedbackId: state.feedbackId + 1,
      ));
    }
  }

  Future<void> _loadSheet() async {
    final classId = state.classId;
    if (classId == null) {
      emit(state.copyWith(
        status: MarkAttendanceStatus.success,
        entries: const [],
        savedEntries: const [],
        alreadyMarked: false,
      ));
      return;
    }
    final id = ++_request;
    emit(state.copyWith(status: MarkAttendanceStatus.loading));
    try {
      final sheet = await _repository.getDailySheet(classId, state.sectionId, state.date);
      if (id != _request) return;
      // Anyone without a saved status is shown as present.
      final entries = [
        for (final e in sheet) e.status == null ? e.withStatus(AttendanceStatus.present) : e,
      ];
      emit(state.copyWith(
        status: MarkAttendanceStatus.success,
        entries: entries,
        // Unsaved defaults count as a change, so Save stays available.
        savedEntries: sheet,
        alreadyMarked: sheet.any((e) => e.status != null),
      ));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  void _fail() {
    emit(state.copyWith(
      status: MarkAttendanceStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
