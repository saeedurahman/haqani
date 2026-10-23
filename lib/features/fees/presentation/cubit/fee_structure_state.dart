import 'package:equatable/equatable.dart';

import '../../domain/fee_models.dart';

enum FeeStructureStatus { initial, loading, success, failure }

class FeeStructureState extends Equatable {
  const FeeStructureState({
    this.status = FeeStructureStatus.initial,
    this.fees = const [],
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final FeeStructureStatus status;
  final List<ClassFee> fees;
  final String? errorMessage;

  /// One-time message after Save. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  FeeStructureState copyWith({
    FeeStructureStatus? status,
    List<ClassFee>? fees,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return FeeStructureState(
      status: status ?? this.status,
      fees: fees ?? this.fees,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props =>
      [status, fees, errorMessage, feedback, feedbackIsError, feedbackId];
}
