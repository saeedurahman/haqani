import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/shell/presentation/cubit/app_section.dart';
import 'package:haqani/features/shell/presentation/cubit/navigation_cubit.dart';

void main() {
  test('starts on the dashboard and switches section', () {
    final cubit = NavigationCubit();
    expect(cubit.state.section, AppSection.dashboard);

    cubit.select(AppSection.fees);

    expect(cubit.state.section, AppSection.fees);
    cubit.close();
  });
}
