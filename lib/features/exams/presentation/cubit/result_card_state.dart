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
  });

  final ResultCardStatus status;

  /// One card for a student, or one per student when printing the whole class.
  final List<ResultCard> cards;

  /// Previous results of the student (empty when printing the whole class).
  final List<ExamSummary> history;
  final Uint8List? pdfBytes;
  final String? errorMessage;

  ResultCardState copyWith({
    ResultCardStatus? status,
    List<ResultCard>? cards,
    List<ExamSummary>? history,
    Uint8List? pdfBytes,
    String? errorMessage,
  }) {
    return ResultCardState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      history: history ?? this.history,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cards, history, pdfBytes, errorMessage];
}
