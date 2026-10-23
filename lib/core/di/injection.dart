import 'package:get_it/get_it.dart';

import '../../features/dashboard/data/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/dashboard_repository.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../database/app_database.dart';

final getIt = GetIt.instance;

/// Registers everything the app needs. Pass [database] in tests.
void configureDependencies({AppDatabase? database}) {
  getIt.registerLazySingleton<AppDatabase>(() => database ?? AppDatabase());

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(getIt<DashboardRepository>()),
  );
}
