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
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final ReceiptStatus status;
  final FeeReceipt? receipt;
  final Uint8List? pdfBytes;
  final String? errorMessage;

  /// One-time message after Send on WhatsApp. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ReceiptState copyWith({
    ReceiptStatus? status,
    FeeReceipt? receipt,
    Uint8List? pdfBytes,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props =>
      [status, receipt, pdfBytes, errorMessage, feedback, feedbackIsError, feedbackId];
}
