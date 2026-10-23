import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/exam_models.dart';
import '../../domain/exams_repository.dart';
import 'subjects_state.dart';

/// Subjects (and their total marks) of each class.
class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit(this._repository) : super(const SubjectsState());

  final ExamsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: SubjectsStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(
        classes: classes,
        classId: () => classes.isEmpty ? null : classes.first.id,
      ));
      await _reload();
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectClass(int? classId) {
    emit(state.copyWith(classId: () => classId));
    return _reload();
  }

  Future<void> save({int id = 0, required String name, required int totalMarks}) {
    final classId = state.classId;
    if (classId == null) return Future.value();
    return _run(
      () => _repository.saveSubject(
        Subject(id: id, classId: classId, name: name, totalMarks: totalMarks),
      ),
      id == 0 ? 'Subject added.' : 'Subject updated.',
    );
  }

  Future<void> delete(int id) => _run(() => _repository.deleteSubject(id), 'Subject deleted.');

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action();
      final subjects = await _repository.getSubjects(state.classId!);
      emit(state.copyWith(
        status: SubjectsStatus.success,
        subjects: subjects,
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

  Future<void> _reload() async {
    final classId = state.classId;
    if (classId == null) {
      emit(state.copyWith(status: SubjectsStatus.success, subjects: const []));
      return;
    }
    try {
      final subjects = await _repository.getSubjects(classId);
      emit(state.copyWith(status: SubjectsStatus.success, subjects: subjects));
    } catch (_) {
      _fail();
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
      status: SubjectsStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
