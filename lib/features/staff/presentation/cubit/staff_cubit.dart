import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/staff_repository.dart';
import 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  StaffCubit(this._repository) : super(const StaffState());

  final StaffRepository _repository;

  /// Only the newest search may update the screen.
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: StaffStatus.loading));
    await _reload();
  }

  Future<void> search(String query) {
    emit(state.copyWith(query: query));
    return _reload();
  }

  Future<void> showInactive(bool value) {
    emit(state.copyWith(includeInactive: value));
    return _reload();
  }

  /// Reloads the list, for example after returning from the form.
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    final id = ++_request;
    try {
      final staff = await _repository.searchStaff(
        query: state.query,
        includeInactive: state.includeInactive,
      );
      if (id != _request) return;
      emit(state.copyWith(status: StaffStatus.success, staff: staff));
    } catch (_) {
      if (id != _request) return;
      emit(state.copyWith(
        status: StaffStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
