import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/attendance_repository.dart';
import 'monthly_report_state.dart';

/// Monthly report: present, absent, leave and percent for every student.
class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  MonthlyReportCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(MonthlyReportState(month: _firstOfMonth((clock ?? DateTime.now)())));

  final AttendanceRepository _repository;
  final DateTime Function() _clock;
  int _request = 0;

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  Future<void> load() async {
    emit(state.copyWith(status: MonthlyReportStatus.loading));
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

  /// Moves the month by [months] (-1 = previous). Months after this one are not allowed.
  Future<void> moveMonth(int months) {
    final next = DateTime(state.month.year, state.month.month + months);
    if (next.isAfter(_firstOfMonth(_clock()))) return Future.value();
    emit(state.copyWith(month: next));
    return _loadReport();
  }

  Future<void> _loadReport() async {
    final classId = state.classId;
    if (classId == null) {
      emit(state.copyWith(status: MonthlyReportStatus.success, rows: const []));
      return;
    }
    final id = ++_request;
    emit(state.copyWith(status: MonthlyReportStatus.loading));
    try {
      final rows = await _repository.getMonthlyReport(
        classId,
        state.sectionId,
        state.month.year,
        state.month.month,
      );
      if (id != _request) return;
      emit(state.copyWith(status: MonthlyReportStatus.success, rows: rows));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  void _fail() {
    emit(state.copyWith(
      status: MonthlyReportStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
