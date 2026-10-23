import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/school_profile.dart';
import '../../domain/settings_repository.dart';
import 'school_profile_cubit.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._schoolProfile) : super(const SettingsState());

  final SettingsRepository _repository;
  final SchoolProfileCubit _schoolProfile;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      emit(state.copyWith(
        status: SettingsStatus.success,
        profile: await _repository.getProfile(),
        dataFolder: await _repository.getDataFolder(),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> save({required String name, String address = '', String phone = ''}) {
    return _run(
      () => _repository.saveProfile(name: name, address: address, phone: phone),
      'School information saved.',
    );
  }

  Future<void> setLogo(String sourcePath) =>
      _run(() => _repository.setLogo(sourcePath), 'Logo saved.');

  Future<void> removeLogo() => _run(_repository.removeLogo, 'Logo removed.');

  Future<void> _run(Future<void> Function() action, String success) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    try {
      await action();
      final profile = await _repository.getProfile();
      await _schoolProfile.load();
      emit(state.copyWith(
        isSaving: false,
        profile: profile,
        feedback: success,
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on SettingsException catch (e) {
      _notify(e.message);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong);
    }
  }

  void _notify(String message) {
    emit(state.copyWith(
      isSaving: false,
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }
}
