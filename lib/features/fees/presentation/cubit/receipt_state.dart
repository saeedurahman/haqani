import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/fee_models.dart';

enum ReceiptStatus { initial, loading, success, failure }

class ReceiptState extends Equatable {
  const ReceiptState({
    this.status = ReceiptStatus.initial,
    this.receipt,
    this.pdfBytes,
    this.errorMessage,
  });

  final ReceiptStatus status;
  final FeeReceipt? receipt;
  final Uint8List? pdfBytes;
  final String? errorMessage;

  ReceiptState copyWith({
    ReceiptStatus? status,
    FeeReceipt? receipt,
    Uint8List? pdfBytes,
    String? errorMessage,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, receipt, pdfBytes, errorMessage];
}
