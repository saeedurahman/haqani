import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/students_repository.dart';
import 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit(this._repository) : super(const StudentsState());

  final StudentsRepository _repository;

  /// Only the newest search may update the screen.
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: StudentsStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(classes: classes));
      await _search();
    } catch (_) {
      _fail();
    }
  }

  Future<void> search(String query) {
    emit(state.copyWith(query: query));
    return _refresh();
  }

  Future<void> filterByClass(int? classId) {
    emit(state.copyWith(classFilter: () => classId));
    return _refresh();
  }

  Future<void> showLeft(bool value) {
    emit(state.copyWith(includeLeft: value));
    return _refresh();
  }

  /// Reloads the list (for example after returning from the form).
  Future<void> refresh() async {
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(classes: classes));
    } catch (_) {
      _fail();
      return;
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      await _search();
    } catch (_) {
      _fail();
    }
  }

  Future<void> _search() async {
    final id = ++_request;
    final students = await _repository.searchStudents(
      query: state.query,
      classId: state.classFilter,
      includeLeft: state.includeLeft,
    );
    if (id != _request) return;
    emit(state.copyWith(status: StudentsStatus.success, students: students));
  }

  void _fail() {
    emit(state.copyWith(
      status: StudentsStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
