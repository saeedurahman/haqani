import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../students/domain/student.dart';
import '../../domain/report_csv.dart';
import '../../domain/report_kind.dart';
import '../../domain/report_models.dart';
import '../../domain/reports_repository.dart';
import 'reports_state.dart';

/// Holds the choices (class, month, dates...) of one report and builds it.
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository, ReportKind kind, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(
        ReportsState(
          kind: kind,
          month: DateTime(
            (clock ?? DateTime.now)().year,
            (clock ?? DateTime.now)().month,
          ),
          // New admissions start with the current month.
          from: kind == ReportKind.admissions
              ? DateTime(
                  (clock ?? DateTime.now)().year,
                  (clock ?? DateTime.now)().month,
                )
              : null,
          to: kind == ReportKind.admissions
              ? DateTime(
                  (clock ?? DateTime.now)().year,
                  (clock ?? DateTime.now)().month,
                  (clock ?? DateTime.now)().day,
                )
              : null,
        ),
      );

  final ReportsRepository _repository;
  final DateTime Function() _clock;

  /// Only the newest report may update the screen.
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      final exams = state.kind == ReportKind.examResults
          ? await _repository.getExamOptions()
          : state.exams;
      emit(
        state.copyWith(
          classes: classes,
          exams: exams,
          // Attendance needs one class; fee reports start with all classes.
          classId: () =>
              state.kind == ReportKind.attendance && classes.isNotEmpty
              ? classes.first.id
              : null,
        ),
      );
      await _build();
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectClass(int? classId) {
    emit(state.copyWith(classId: () => classId, sectionId: () => null));
    return _build();
  }

  Future<void> selectSection(int? sectionId) {
    emit(state.copyWith(sectionId: () => sectionId));
    return _build();
  }

  /// Moves the month. Months after this one are not allowed.
  Future<void> moveMonth(int months) {
    final next = DateTime(state.month.year, state.month.month + months);
    final now = _clock();
    if (next.isAfter(DateTime(now.year, now.month))) return Future.value();
    emit(state.copyWith(month: next));
    return _build();
  }

  Future<void> setRange({DateTime? from, DateTime? to}) {
    emit(state.copyWith(from: () => from, to: () => to));
    return _build();
  }

  Future<void> setFeeStatus(String? status) {
    emit(state.copyWith(feeStatus: () => status));
    return _build();
  }

  Future<void> selectExam(int? examId) {
    emit(state.copyWith(examId: () => examId));
    return _build();
  }

  Future<void> searchStudents(String query) async {
    try {
      emit(
        state.copyWith(studentMatches: await _repository.findStudents(query)),
      );
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectStudent(Student? student) {
    emit(state.copyWith(student: () => student, studentMatches: const []));
    return _build();
  }

  /// Filters the rows on screen and in the exported file.
  void search(String text) => emit(state.copyWith(search: text));

  Uint8List? csvBytes() {
    final doc = state.visibleDocument;
    return doc == null ? null : ReportCsv.bytes(doc);
  }

  String csvFileName() =>
      '${state.kind.name}_report_${AppDateUtils.toIso(_clock())}.csv';

  Future<void> _build() async {
    // Attendance has no class to show when the school has no classes yet.
    final noClass =
        state.kind == ReportKind.attendance && state.classId == null;
    if (state.needsChoice || noClass) {
      emit(state.copyWith(status: ReportsStatus.success, document: () => null));
      return;
    }
    final id = ++_request;
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final document = await _create();
      if (id != _request) return;
      emit(
        state.copyWith(status: ReportsStatus.success, document: () => document),
      );
    } on ReportsException catch (e) {
      if (id != _request) return;
      emit(
        state.copyWith(status: ReportsStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  Future<ReportDocument> _create() {
    final s = state;
    switch (s.kind) {
      case ReportKind.students:
        return _repository.studentsReport();
      case ReportKind.admissions:
        return _repository.admissionsReport(from: s.from, to: s.to);
      case ReportKind.attendance:
        final classId = s.classId;
        if (classId == null) throw const ReportsException('Choose a class.');
        return _repository.attendanceReport(
          classId: classId,
          sectionId: s.sectionId,
          year: s.month.year,
          month: s.month.month,
        );
      case ReportKind.fees:
        return _repository.feesReport(
          month: AppDateUtils.toMonth(s.month),
          classId: s.classId,
          status: s.feeStatus,
        );
      case ReportKind.defaulters:
        return _repository.defaultersReport(classId: s.classId);
      case ReportKind.examResults:
        return _repository.examResultsReport(s.examId!);
      case ReportKind.studentHistory:
        return _repository.studentHistoryReport(s.student!.id);
    }
  }

  void _fail() {
    emit(
      state.copyWith(
        status: ReportsStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ),
    );
  }
}
