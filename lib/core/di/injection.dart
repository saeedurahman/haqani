import 'package:get_it/get_it.dart';

import '../../features/classes/data/classes_repository_impl.dart';
import '../../features/classes/domain/classes_repository.dart';
import '../../features/classes/presentation/cubit/classes_cubit.dart';
import '../../features/students/data/students_repository_impl.dart';
import '../../features/students/domain/students_repository.dart';
import '../../features/students/presentation/cubit/student_detail_cubit.dart';
import '../../features/students/presentation/cubit/student_form_cubit.dart';
import '../../features/students/presentation/cubit/students_cubit.dart';
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

  getIt.registerLazySingleton<ClassesRepository>(
    () => ClassesRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<ClassesCubit>(
    () => ClassesCubit(getIt<ClassesRepository>()),
  );

  getIt.registerLazySingleton<StudentsRepository>(
    () => StudentsRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<StudentsCubit>(
    () => StudentsCubit(getIt<StudentsRepository>()),
  );
  getIt.registerFactory<StudentFormCubit>(
    () => StudentFormCubit(getIt<StudentsRepository>()),
  );
  getIt.registerFactory<StudentDetailCubit>(
    () => StudentDetailCubit(getIt<StudentsRepository>()),
  );
}
