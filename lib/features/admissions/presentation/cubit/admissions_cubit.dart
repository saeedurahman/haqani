import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/admissions_repository.dart';
import 'admissions_state.dart';

class AdmissionsCubit extends Cubit<AdmissionsState> {
  AdmissionsCubit(this._repository) : super(const AdmissionsState());

  final AdmissionsRepository _repository;

  /// Only the newest request may update the screen.
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: AdmissionsStatus.loading));
    await _reload();
  }

  Future<void> search(String query) {
    emit(state.copyWith(query: query));
    return _reload();
  }

  /// Pass null to clear a side of the date range.
  Future<void> setRange({DateTime? from, DateTime? to}) {
    emit(state.copyWith(from: () => from, to: () => to));
    return _reload();
  }

  /// Reloads the list, for example after returning from the form.
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    final id = ++_request;
    try {
      final students = await _repository.getAdmissions(
        query: state.query,
        from: state.from,
        to: state.to,
      );
      if (id != _request) return;
      emit(state.copyWith(status: AdmissionsStatus.success, students: students));
    } catch (_) {
      if (id != _request) return;
      emit(state.copyWith(
        status: AdmissionsStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
