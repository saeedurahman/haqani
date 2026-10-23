import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/students_exception.dart';
import '../../domain/students_repository.dart';
import 'student_detail_state.dart';

class StudentDetailCubit extends Cubit<StudentDetailState> {
  StudentDetailCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const StudentDetailState());

  final StudentsRepository _repository;
  final DateTime Function() _clock;

  Future<void> load(int studentId) async {
    if (state.student == null) {
      emit(state.copyWith(status: StudentDetailStatus.loading));
    }
    try {
      final student = await _repository.getStudent(studentId);
      if (student == null) {
        emit(state.copyWith(
          status: StudentDetailStatus.failure,
          errorMessage: 'This student was not found.',
        ));
        return;
      }
      emit(state.copyWith(
        status: StudentDetailStatus.success,
        student: student,
        documents: await _repository.getDocuments(studentId),
        history: await _repository.getHistory(studentId),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StudentDetailStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> markAsLeft() {
    final student = state.student!;
    return _run(
      () => _repository.markAsLeft(student.id, _clock()),
      '${student.name} is marked as left.',
    );
  }

  Future<void> reactivate() {
    final student = state.student!;
    return _run(
      () => _repository.reactivate(student.id),
      '${student.name} is active again.',
    );
  }

  Future<void> addDocument(String title, String sourcePath) => _run(
        () => _repository.addDocument(state.student!.id, title, sourcePath),
        'Document added.',
      );

  Future<void> deleteDocument(int documentId) => _run(
        () => _repository.deleteDocument(documentId),
        'Document removed.',
      );

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action();
      final id = state.student!.id;
      final student = await _repository.getStudent(id);
      emit(state.copyWith(
        student: student,
        documents: await _repository.getDocuments(id),
        feedback: success,
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on StudentsException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }
}
