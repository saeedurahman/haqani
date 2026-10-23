import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_section.dart';

class NavigationState extends Equatable {
  const NavigationState({this.section = AppSection.dashboard});

  final AppSection section;

  @override
  List<Object?> get props => [section];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void select(AppSection section) => emit(NavigationState(section: section));
}
