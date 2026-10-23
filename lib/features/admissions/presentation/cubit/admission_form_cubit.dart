import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../students/domain/student.dart';
import '../../../students/domain/students_exception.dart';
import '../../domain/admissions_repository.dart';
import 'admission_form_state.dart';

class AdmissionFormCubit extends Cubit<AdmissionFormState> {
  AdmissionFormCubit(this._repository) : super(const AdmissionFormState());

  final AdmissionsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: AdmissionFormStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      final next = await _repository.nextAdmissionNo();
      emit(state.copyWith(
        status: AdmissionFormStatus.ready,
        classes: classes,
        nextAdmissionNo: next,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdmissionFormStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> admit(Student student) async {
    emit(state.copyWith(status: AdmissionFormStatus.saving));
    try {
      final saved = await _repository.admit(student);
      emit(state.copyWith(status: AdmissionFormStatus.saved, admitted: saved));
    } on StudentsException catch (e) {
      emit(state.copyWith(status: AdmissionFormStatus.ready, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: AdmissionFormStatus.ready,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
