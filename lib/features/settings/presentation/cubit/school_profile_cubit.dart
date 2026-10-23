import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/school_profile.dart';
import '../../domain/settings_repository.dart';

class SchoolProfileState extends Equatable {
  const SchoolProfileState({
    this.profile = const SchoolProfile(name: AppStrings.defaultSchoolName),
  });

  final SchoolProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// The school name and logo shown in the side menu. One for the whole app;
/// the Settings page asks it to reload after a save.
class SchoolProfileCubit extends Cubit<SchoolProfileState> {
  SchoolProfileCubit(this._repository) : super(const SchoolProfileState());

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      emit(SchoolProfileState(profile: await _repository.getProfile()));
    } catch (_) {
      // The default name stays when the settings cannot be read.
    }
  }
}
