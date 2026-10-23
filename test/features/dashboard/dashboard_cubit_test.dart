import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/dashboard/domain/dashboard_repository.dart';
import 'package:haqani/features/dashboard/domain/dashboard_summary.dart';
import 'package:haqani/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:haqani/features/dashboard/presentation/cubit/dashboard_state.dart';

class _FakeRepository implements DashboardRepository {
  _FakeRepository({this.fail = false});

  final bool fail;
  DateTime? requestedDay;

  @override
  Future<DashboardSummary> loadSummary(DateTime today) async {
    requestedDay = today;
    if (fail) throw Exception('database error');
    return const DashboardSummary(
      schoolName: 'Test School',
      totalStudents: 12,
      totalStaff: 3,
      presentToday: 10,
      feesCollectedThisMonth: 4500,
    );
  }
}

void main() {
  final day = DateTime(2026, 5, 12);

  test('load emits loading then success with the summary', () async {
    final repository = _FakeRepository();
    final cubit = DashboardCubit(repository, clock: () => day);

    final states = <DashboardState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.map((s) => s.status), [
      DashboardStatus.loading,
      DashboardStatus.success,
    ]);
    expect(cubit.state.summary?.totalStudents, 12);
    expect(repository.requestedDay, day);

    await sub.cancel();
    await cubit.close();
  });

  test('load emits a friendly failure message on error', () async {
    final cubit = DashboardCubit(_FakeRepository(fail: true), clock: () => day);

    await cubit.load();

    expect(cubit.state.status, DashboardStatus.failure);
    expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
    await cubit.close();
  });
}
