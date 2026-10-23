import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const DashboardState());

  final DashboardRepository _repository;
  final DateTime Function() _clock;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final summary = await _repository.loadSummary(_clock());
      emit(state.copyWith(status: DashboardStatus.success, summary: summary));
    } catch (_) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
