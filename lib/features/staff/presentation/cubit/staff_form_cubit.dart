import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/staff_exception.dart';
import '../../domain/staff_member.dart';
import '../../domain/staff_repository.dart';
import 'staff_form_state.dart';

class StaffFormCubit extends Cubit<StaffFormState> {
  StaffFormCubit(this._repository) : super(const StaffFormState());

  final StaffRepository _repository;

  /// Pass [staffId] to edit, or null to add a new person.
  Future<void> load({int? staffId}) async {
    if (staffId == null) {
      emit(state.copyWith(status: StaffFormStatus.ready));
      return;
    }
    emit(state.copyWith(status: StaffFormStatus.loading));
    try {
      final member = await _repository.getStaff(staffId);
      if (member == null) {
        emit(state.copyWith(
          status: StaffFormStatus.failure,
          errorMessage: 'This person was not found.',
        ));
        return;
      }
      emit(state.copyWith(status: StaffFormStatus.ready, member: member));
    } catch (_) {
      emit(state.copyWith(
        status: StaffFormStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> save(StaffMember member) async {
    emit(state.copyWith(status: StaffFormStatus.saving));
    try {
      await _repository.saveStaff(member);
      emit(state.copyWith(status: StaffFormStatus.saved));
    } on StaffException catch (e) {
      emit(state.copyWith(status: StaffFormStatus.ready, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: StaffFormStatus.ready,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  /// Hides the person from the main list (or brings them back). Nothing is deleted.
  Future<void> setActive({required bool active}) async {
    final member = state.member;
    if (member == null) return;
    try {
      await _repository.setActive(member.id, active: active);
      final updated = await _repository.getStaff(member.id);
      emit(state.copyWith(
        member: updated,
        feedback: active ? '${member.name} is active again.' : '${member.name} is marked as left.',
        feedbackId: state.feedbackId + 1,
      ));
    } catch (_) {
      emit(state.copyWith(
        feedback: AppStrings.somethingWentWrong,
        feedbackId: state.feedbackId + 1,
      ));
    }
  }
}
