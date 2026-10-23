import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/certificate_cubit.dart';
import '../cubit/certificate_state.dart';
import '../widgets/certificate_form_panel.dart';

class LeavingCertificatePage extends StatelessWidget {
  const LeavingCertificatePage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CertificateCubit>()..load(studentId),
      child: _CertificateView(studentId: studentId),
    );
  }
}

class _CertificateView extends StatelessWidget {
  const _CertificateView({required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('School Leaving Certificate'),
      ),
      body: BlocBuilder<CertificateCubit, CertificateState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          switch (state.status) {
            case CertificateStatus.initial:
            case CertificateStatus.loading:
              return const LoadingView();
            case CertificateStatus.failure:
              return ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<CertificateCubit>().load(studentId),
              );
            case CertificateStatus.success:
              return const _Editor();
          }
        },
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CertificateCubit>();
    final initial = cubit.state.certificate!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        8,
        AppConstants.pagePadding,
        AppConstants.pagePadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 16),
                child: CertificateFormPanel(initial: initial, onChanged: cubit.update),
              ),
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(child: _Preview()),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (a, b) => a.pdfBytes != b.pdfBytes,
      builder: (context, state) {
        final bytes = state.pdfBytes;
        if (bytes == null) return const LoadingView(message: 'Preparing certificate...');
        final admissionNo = state.certificate?.admissionNo ?? '';
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColoredBox(
            color: AppColors.border,
            child: PdfPreview(
              build: (_) async => bytes,
              pdfFileName: 'leaving_certificate_$admissionNo.pdf',
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              maxPageWidth: 640,
            ),
          ),
        );
      },
    );
  }
}
