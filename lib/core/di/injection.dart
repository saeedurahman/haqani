import 'package:get_it/get_it.dart';

import '../../features/admissions/data/admissions_repository_impl.dart';
import '../../features/admissions/data/leaving_certificate_pdf.dart';
import '../../features/admissions/domain/admissions_repository.dart';
import '../../features/admissions/domain/certificate_pdf_service.dart';
import '../../features/admissions/presentation/cubit/admission_form_cubit.dart';
import '../../features/admissions/presentation/cubit/admissions_cubit.dart';
import '../../features/admissions/presentation/cubit/certificate_cubit.dart';
import '../../features/attendance/data/attendance_repository_impl.dart';
import '../../features/attendance/domain/attendance_repository.dart';
import '../../features/attendance/presentation/cubit/daily_report_cubit.dart';
import '../../features/attendance/presentation/cubit/mark_attendance_cubit.dart';
import '../../features/attendance/presentation/cubit/monthly_report_cubit.dart';
import '../../features/fees/data/fee_receipt_pdf.dart';
import '../../features/fees/data/fees_repository_impl.dart';
import '../../features/fees/domain/fees_repository.dart';
import '../../features/fees/domain/receipt_pdf_service.dart';
import '../../features/fees/presentation/cubit/collect_fee_cubit.dart';
import '../../features/fees/presentation/cubit/fee_structure_cubit.dart';
import '../../features/fees/presentation/cubit/receipt_cubit.dart';
import '../../features/fees/presentation/cubit/vouchers_cubit.dart';
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

  getIt.registerLazySingleton<CertificatePdfService>(() => LeavingCertificatePdf());
  getIt.registerLazySingleton<AdmissionsRepository>(
    () => AdmissionsRepositoryImpl(getIt<AppDatabase>(), getIt<StudentsRepository>()),
  );
  getIt.registerFactory<AdmissionsCubit>(
    () => AdmissionsCubit(getIt<AdmissionsRepository>()),
  );
  getIt.registerFactory<AdmissionFormCubit>(
    () => AdmissionFormCubit(getIt<AdmissionsRepository>()),
  );
  getIt.registerFactory<CertificateCubit>(
    () => CertificateCubit(getIt<AdmissionsRepository>(), getIt<CertificatePdfService>()),
  );

  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<MarkAttendanceCubit>(
    () => MarkAttendanceCubit(getIt<AttendanceRepository>()),
  );
  getIt.registerFactory<DailyReportCubit>(
    () => DailyReportCubit(getIt<AttendanceRepository>()),
  );
  getIt.registerFactory<MonthlyReportCubit>(
    () => MonthlyReportCubit(getIt<AttendanceRepository>()),
  );

  getIt.registerLazySingleton<ReceiptPdfService>(() => FeeReceiptPdf());
  getIt.registerLazySingleton<FeesRepository>(
    () => FeesRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<FeeStructureCubit>(
    () => FeeStructureCubit(getIt<FeesRepository>()),
  );
  getIt.registerFactory<VouchersCubit>(
    () => VouchersCubit(getIt<FeesRepository>()),
  );
  getIt.registerFactory<CollectFeeCubit>(
    () => CollectFeeCubit(getIt<FeesRepository>()),
  );
  getIt.registerFactory<ReceiptCubit>(
    () => ReceiptCubit(getIt<FeesRepository>(), getIt<ReceiptPdfService>()),
  );
}
