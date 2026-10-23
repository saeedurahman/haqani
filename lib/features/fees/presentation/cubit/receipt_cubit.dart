import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/fee_models.dart';
import '../../domain/fees_repository.dart';
import '../../domain/receipt_pdf_service.dart';
import 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  ReceiptCubit(this._repository, this._pdf) : super(const ReceiptState());

  final FeesRepository _repository;
  final ReceiptPdfService _pdf;

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
