import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/student.dart';
import '../../domain/students_exception.dart';
import '../../domain/students_repository.dart';
import 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  StudentFormCubit(this._repository) : super(const StudentFormState());

  final StudentsRepository _repository;

  /// Pass [studentId] to edit, or null to add a new student.
  Future<void> load({int? studentId}) async {
    emit(state.copyWith(status: StudentFormStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      if (studentId == null) {
        final suggested = await _repository.suggestAdmissionNo();
        emit(state.copyWith(
          status: StudentFormStatus.ready,
          classes: classes,
          suggestedAdmissionNo: suggested,
        ));
        return;
      }
      final student = await _repository.getStudent(studentId);
      if (student == null) {
        emit(state.copyWith(
          status: StudentFormStatus.failure,
          errorMessage: 'This student was not found.',
        ));
        return;
      }
      emit(state.copyWith(
        status: StudentFormStatus.ready,
        classes: classes,
        student: student,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StudentFormStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> save(Student student) async {
    emit(state.copyWith(status: StudentFormStatus.saving));
    try {
      final id = await _repository.saveStudent(student);
      emit(state.copyWith(status: StudentFormStatus.saved, savedId: id));
    } on StudentsException catch (e) {
      emit(state.copyWith(status: StudentFormStatus.ready, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: StudentFormStatus.ready,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
