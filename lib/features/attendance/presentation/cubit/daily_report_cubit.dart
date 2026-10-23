import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/attendance_repository.dart';
import 'daily_report_state.dart';

/// Date-wise report: who was present, absent or on leave in one class on one day.
class DailyReportCubit extends Cubit<DailyReportState> {
  DailyReportCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(DailyReportState(date: _dateOnly((clock ?? DateTime.now)())));

  final AttendanceRepository _repository;
  final DateTime Function() _clock;
  int _request = 0;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> load() async {
    emit(state.copyWith(status: DailyReportStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(
        classes: classes,
        classId: () => classes.isEmpty ? null : classes.first.id,
        sectionId: () => null,
      ));
      await _loadReport();
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectClass(int? classId) {
    emit(state.copyWith(classId: () => classId, sectionId: () => null));
    return _loadReport();
  }

  Future<void> selectSection(int? sectionId) {
    emit(state.copyWith(sectionId: () => sectionId));
    return _loadReport();
  }

  Future<void> selectDate(DateTime date) {
    final today = _dateOnly(_clock());
    final day = _dateOnly(date);
    emit(state.copyWith(date: day.isAfter(today) ? today : day));
    return _loadReport();
  }

  Future<void> _loadReport() async {
    final classId = state.classId;
    if (classId == null) {
      emit(state.copyWith(status: DailyReportStatus.success, entries: const []));
      return;
    }
    final id = ++_request;
    emit(state.copyWith(status: DailyReportStatus.loading));
    try {
      final entries = await _repository.getDailySheet(classId, state.sectionId, state.date);
      if (id != _request) return;
      emit(state.copyWith(status: DailyReportStatus.success, entries: entries));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  void _fail() {
    emit(state.copyWith(
      status: DailyReportStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
