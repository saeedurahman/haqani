import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../domain/fee_models.dart';
import '../cubit/receipt_cubit.dart';
import '../cubit/receipt_state.dart';

/// Shows the receipt as a PDF with Print and Save. Give [receipt] right after a
/// payment, or [receiptNo] to print an old one again.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, this.receipt, this.receiptNo});

  final FeeReceipt? receipt;
  final String? receiptNo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReceiptCubit>()..load(receipt: receipt, receiptNo: receiptNo),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Receipt No ${receipt?.receiptNo ?? receiptNo}'),
          actions: [
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.pagePadding),
                child: WhatsAppButton(onPressed: () => context.read<ReceiptCubit>().sendWhatsApp()),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ReceiptCubit, ReceiptState>(
          listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
          listener: (context, state) {
            if (state.feedbackIsError) {
              Snack.error(context, state.feedback!);
            } else {
              Snack.success(context, state.feedback!);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case ReceiptStatus.initial:
              case ReceiptStatus.loading:
                return const LoadingView(message: 'Preparing receipt...');
              case ReceiptStatus.failure:
                return ErrorView(message: state.errorMessage);
              case ReceiptStatus.success:
                final bytes = state.pdfBytes!;
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
                        pdfFileName: 'fee_receipt_${state.receipt!.receiptNo}.pdf',
                        initialPageFormat: PdfPageFormat.a5,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        maxPageWidth: 520,
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
