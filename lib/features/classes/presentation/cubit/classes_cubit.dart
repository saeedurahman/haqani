import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/classes_exception.dart';
import '../../domain/classes_repository.dart';
import 'classes_state.dart';

class ClassesCubit extends Cubit<ClassesState> {
  ClassesCubit(this._repository) : super(const ClassesState());

  final ClassesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ClassesStatus.loading, query: state.query));
    try {
      final classes = await _repository.getClasses();
      final teachers = await _repository.getTeachers();
      emit(
        state.copyWith(
          status: ClassesStatus.success,
          classes: classes,
          teachers: teachers,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ClassesStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  void search(String query) => emit(
    state.copyWith(
      query: query,
      classes: state.classes,
      teachers: state.teachers,
    ),
  );

  Future<void> addClass(String name) =>
      _run(() => _repository.addClass(name), 'Class added.');

  Future<void> renameClass(int id, String name) =>
      _run(() => _repository.renameClass(id, name), 'Class updated.');

  Future<void> deleteClass(int id) =>
      _run(() => _repository.deleteClass(id), 'Class deleted.');

  /// Moves a class one step up (-1) or down (+1) in the list.
  Future<void> moveClass(int id, int direction) async {
    final ids = [for (final c in state.classes) c.id];
    final from = ids.indexOf(id);
    final to = from + direction;
    if (from < 0 || to < 0 || to >= ids.length) return;
    ids.insert(to, ids.removeAt(from));
    await _run(() => _repository.saveClassOrder(ids), null);
  }

  Future<void> addSection(int classId, String name, {int? teacherId}) => _run(
    () => _repository.addSection(classId, name, teacherId: teacherId),
    'Section added.',
  );

  Future<void> updateSection(int id, String name, {int? teacherId}) => _run(
    () => _repository.updateSection(id, name, teacherId: teacherId),
    'Section updated.',
  );

  Future<void> deleteSection(int id) =>
      _run(() => _repository.deleteSection(id), 'Section deleted.');

  Future<void> _run(Future<void> Function() action, String? success) async {
    try {
      await action();
      final classes = await _repository.getClasses();
      emit(
        state.copyWith(
          status: ClassesStatus.success,
          classes: classes,
          teachers: state.teachers,
          feedback: success,
          feedbackIsError: false,
          feedbackId: state.feedbackId + 1,
        ),
      );
    } on ClassesException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  void _emitError(String message) {
    emit(
      state.copyWith(
        classes: state.classes,
        teachers: state.teachers,
        feedback: message,
        feedbackIsError: true,
        feedbackId: state.feedbackId + 1,
      ),
    );
  }
}
