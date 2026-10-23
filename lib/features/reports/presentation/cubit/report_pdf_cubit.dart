import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/report_models.dart';
import '../../domain/report_pdf_service.dart';
import '../../domain/reports_repository.dart';
import 'report_pdf_state.dart';

class ReportPdfCubit extends Cubit<ReportPdfState> {
  ReportPdfCubit(this._repository, this._pdf) : super(const ReportPdfState());

  final ReportsRepository _repository;
  final ReportPdfService _pdf;

  Future<void> build(ReportDocument document) async {
    emit(const ReportPdfState(status: ReportPdfStatus.loading));
    try {
      final school = await _repository.getSchoolInfo();
      final bytes = await _pdf.build(document, school);
      emit(ReportPdfState(status: ReportPdfStatus.success, bytes: bytes));
    } catch (_) {
      emit(
        const ReportPdfState(
          status: ReportPdfStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }
}
