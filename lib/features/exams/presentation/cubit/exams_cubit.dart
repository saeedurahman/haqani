import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/exam_models.dart';
import '../../domain/exams_repository.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit(this._repository) : super(const ExamsState());

  final ExamsRepository _repository;
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: ExamsStatus.loading));
    try {
      emit(state.copyWith(classes: await _repository.getClassOptions()));
      await _reload();
    } catch (_) {
      _fail();
    }
  }

  Future<void> filterByClass(int? classId) {
    emit(state.copyWith(classFilter: () => classId));
    return _reload();
  }

  Future<void> search(String query) {
    emit(state.copyWith(query: query));
    return _reload();
  }

  /// Reloads the list, for example after coming back from an exam.
  Future<void> refresh() => _reload();

  Future<void> saveExam(Exam exam) => _run(
        () => _repository.saveExam(exam),
        exam.id == 0 ? 'Exam created.' : 'Exam updated.',
      );

  Future<void> deleteExam(int id) => _run(() => _repository.deleteExam(id), 'Exam deleted.');

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action();
      final exams = await _load();
      emit(state.copyWith(
        status: ExamsStatus.success,
        exams: exams,
        feedback: success,
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on ExamsException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  Future<List<Exam>> _load() =>
      _repository.getExams(classId: state.classFilter, query: state.query);

  Future<void> _reload() async {
    final id = ++_request;
    try {
      final exams = await _load();
      if (id != _request) return;
      emit(state.copyWith(status: ExamsStatus.success, exams: exams));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }

  void _fail() {
    emit(state.copyWith(
      status: ExamsStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
