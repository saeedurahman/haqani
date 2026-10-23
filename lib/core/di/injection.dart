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
import '../../features/staff/data/staff_repository_impl.dart';
import '../../features/staff/domain/staff_repository.dart';
import '../../features/staff/presentation/cubit/staff_cubit.dart';
import '../../features/staff/presentation/cubit/staff_form_cubit.dart';
import '../../features/exams/data/exams_repository_impl.dart';
import '../../features/exams/data/result_card_pdf.dart';
import '../../features/exams/domain/exams_repository.dart';
import '../../features/exams/domain/result_card_pdf_service.dart';
import '../../features/exams/presentation/cubit/exams_cubit.dart';
import '../../features/exams/presentation/cubit/marks_cubit.dart';
import '../../features/exams/presentation/cubit/result_card_cubit.dart';
import '../../features/exams/presentation/cubit/subjects_cubit.dart';
import '../../features/reports/data/report_pdf.dart';
import '../../features/reports/data/reports_repository_impl.dart';
import '../../features/reports/domain/report_pdf_service.dart';
import '../../features/reports/domain/reports_repository.dart';
import '../../features/reports/domain/report_kind.dart';
import '../../features/reports/presentation/cubit/report_pdf_cubit.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';
import '../../features/backup/data/backup_file_service.dart';
import '../../features/backup/data/backup_repository_impl.dart';
import '../../features/backup/data/google_drive_service_impl.dart';
import '../../features/backup/data/settings_store.dart';
import '../../features/backup/domain/backup_repository.dart';
import '../../features/backup/domain/google_drive_service.dart';
import '../../features/backup/presentation/cubit/backup_cubit.dart';
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
import '../services/app_paths.dart';
import '../services/app_restarter.dart';
import '../services/whatsapp_service.dart';

final getIt = GetIt.instance;

/// Registers everything the app needs. Pass [database] in tests.
void configureDependencies({AppDatabase? database}) {
  getIt.registerLazySingleton<AppDatabase>(() => database ?? AppDatabase());
  getIt.registerLazySingleton<WhatsAppService>(
    () => WhatsAppServiceImpl(getIt<AppDatabase>()),
  );

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
    () => StudentDetailCubit(getIt<StudentsRepository>(), getIt<WhatsAppService>()),
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
    () => MarkAttendanceCubit(getIt<AttendanceRepository>(), getIt<WhatsAppService>()),
  );
  getIt.registerFactory<DailyReportCubit>(
    () => DailyReportCubit(getIt<AttendanceRepository>(), getIt<WhatsAppService>()),
  );
  getIt.registerFactory<MonthlyReportCubit>(
    () => MonthlyReportCubit(getIt<AttendanceRepository>(), getIt<WhatsAppService>()),
  );

  getIt.registerLazySingleton<ReceiptPdfService>(() => FeeReceiptPdf());
  getIt.registerLazySingleton<FeesRepository>(
    () => FeesRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<FeeStructureCubit>(
    () => FeeStructureCubit(getIt<FeesRepository>()),
  );
  getIt.registerFactory<VouchersCubit>(
    () => VouchersCubit(getIt<FeesRepository>(), getIt<WhatsAppService>()),
  );
  getIt.registerFactory<CollectFeeCubit>(
    () => CollectFeeCubit(getIt<FeesRepository>()),
  );
  getIt.registerFactory<ReceiptCubit>(
    () => ReceiptCubit(
      getIt<FeesRepository>(),
      getIt<ReceiptPdfService>(),
      getIt<WhatsAppService>(),
    ),
  );

  getIt.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<StaffCubit>(() => StaffCubit(getIt<StaffRepository>()));
  getIt.registerFactory<StaffFormCubit>(
    () => StaffFormCubit(getIt<StaffRepository>()),
  );

  getIt.registerLazySingleton<ResultCardPdfService>(() => ResultCardPdf());
  getIt.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory<ExamsCubit>(() => ExamsCubit(getIt<ExamsRepository>()));
  getIt.registerFactory<SubjectsCubit>(
    () => SubjectsCubit(getIt<ExamsRepository>()),
  );
  getIt.registerFactory<MarksCubit>(() => MarksCubit(getIt<ExamsRepository>()));
  getIt.registerFactory<ResultCardCubit>(
    () => ResultCardCubit(
      getIt<ExamsRepository>(),
      getIt<ResultCardPdfService>(),
      getIt<WhatsAppService>(),
    ),
  );

  getIt.registerLazySingleton<ReportPdfService>(() => ReportPdf());
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      students: getIt<StudentsRepository>(),
      admissions: getIt<AdmissionsRepository>(),
      attendance: getIt<AttendanceRepository>(),
      fees: getIt<FeesRepository>(),
      exams: getIt<ExamsRepository>(),
    ),
  );
  getIt.registerFactoryParam<ReportsCubit, ReportKind, void>(
    (kind, _) => ReportsCubit(getIt<ReportsRepository>(), kind),
  );
  getIt.registerFactory<ReportPdfCubit>(
    () => ReportPdfCubit(getIt<ReportsRepository>(), getIt<ReportPdfService>()),
  );

  getIt.registerLazySingleton<AppPaths>(() => AppPaths());
  getIt.registerLazySingleton<AppRestarter>(() => const ProcessAppRestarter());
  getIt.registerLazySingleton<SettingsStore>(() => SettingsStore(getIt<AppDatabase>()));
  getIt.registerLazySingleton<GoogleDriveService>(
    () => GoogleDriveServiceImpl(getIt<SettingsStore>()),
  );
  getIt.registerLazySingleton<BackupRepository>(
    () => BackupRepositoryImpl(
      db: getIt<AppDatabase>(),
      paths: getIt<AppPaths>(),
      files: BackupFileService(getIt<AppPaths>()),
      drive: getIt<GoogleDriveService>(),
      settings: getIt<SettingsStore>(),
    ),
  );
  getIt.registerFactory<BackupCubit>(
    () => BackupCubit(getIt<BackupRepository>(), getIt<AppRestarter>()),
  );
}
