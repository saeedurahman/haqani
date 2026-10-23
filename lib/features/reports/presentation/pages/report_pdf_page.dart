import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/report_models.dart';
import '../cubit/report_pdf_cubit.dart';
import '../cubit/report_pdf_state.dart';

/// Shows a report as a PDF, with Print and Save.
class ReportPdfPage extends StatelessWidget {
  const ReportPdfPage({
    super.key,
    required this.document,
    required this.fileName,
  });

  final ReportDocument document;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportPdfCubit>()..build(document),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(document.title),
        ),
        body: BlocBuilder<ReportPdfCubit, ReportPdfState>(
          builder: (context, state) {
            switch (state.status) {
              case ReportPdfStatus.initial:
              case ReportPdfStatus.loading:
                return const LoadingView(message: 'Preparing PDF...');
              case ReportPdfStatus.failure:
                return ErrorView(message: state.errorMessage);
              case ReportPdfStatus.success:
                final bytes = state.bytes!;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    8,
                    AppConstants.pagePadding,
                    AppConstants.pagePadding,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ColoredBox(
                      color: AppColors.border,
                      child: PdfPreview(
                        build: (_) async => bytes,
                        pdfFileName: fileName,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        maxPageWidth: 760,
                      ),
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
