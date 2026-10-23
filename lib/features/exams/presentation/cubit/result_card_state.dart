import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/result_card.dart';

enum ResultCardStatus { initial, loading, success, failure }

class ResultCardState extends Equatable {
  const ResultCardState({
    this.status = ResultCardStatus.initial,
    this.cards = const [],
    this.history = const [],
    this.pdfBytes,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final ResultCardStatus status;

  /// One card for a student, or one per student when printing the whole class.
  final List<ResultCard> cards;

  /// Previous results of the student (empty when printing the whole class).
  final List<ExamSummary> history;
  final Uint8List? pdfBytes;
  final String? errorMessage;

  /// One-time message after Send on WhatsApp. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ResultCardState copyWith({
    ResultCardStatus? status,
    List<ResultCard>? cards,
    List<ExamSummary>? history,
    Uint8List? pdfBytes,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return ResultCardState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      history: history ?? this.history,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props =>
      [status, cards, history, pdfBytes, errorMessage, feedback, feedbackIsError, feedbackId];
}
