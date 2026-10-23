import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/whatsapp_messages.dart';
import '../../domain/fee_models.dart';
import '../../domain/fees_repository.dart';
import '../../domain/receipt_pdf_service.dart';
import 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  ReceiptCubit(this._repository, this._pdf, this._whatsApp) : super(const ReceiptState());

  final FeesRepository _repository;
  final ReceiptPdfService _pdf;
  final WhatsAppService _whatsApp;

  /// Opens WhatsApp with the receipt details for the parent.
  /// Brothers and sisters on one receipt go to the first student's parent.
  Future<void> sendWhatsApp() async {
    final receipt = state.receipt;
    if (receipt == null || receipt.lines.isEmpty) return;
    final result = await _whatsApp.sendToParent(
      studentId: receipt.lines.first.voucher.student.id,
      body: WhatsAppMessages.feeReceipt(
        studentNames: [for (final l in receipt.lines) l.voucher.student.name],
        receiptNo: receipt.receiptNo,
        date: receipt.date,
        received: receipt.lines.fold(0, (sum, l) => sum + (l.receivedNow ?? l.voucher.paidAmount)),
        balance: receipt.totalBalance,
      ),
    );
    emit(state.copyWith(
      feedback: result.userMessage,
      feedbackIsError: result.isError,
      feedbackId: state.feedbackId + 1,
    ));
  }

  /// Pass [receipt] when you already have it, otherwise it is loaded by [receiptNo].
  Future<void> load({String? receiptNo, FeeReceipt? receipt}) async {
    emit(state.copyWith(status: ReceiptStatus.loading));
    try {
      final found = receipt ?? await _repository.getReceipt(receiptNo ?? '');
      if (found == null) {
        emit(state.copyWith(
          status: ReceiptStatus.failure,
          errorMessage: 'This receipt was not found.',
        ));
        return;
      }
      final bytes = await _pdf.build(found);
      emit(state.copyWith(status: ReceiptStatus.success, receipt: found, pdfBytes: bytes));
    } catch (_) {
      emit(state.copyWith(
        status: ReceiptStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }
}
