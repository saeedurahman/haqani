import 'package:equatable/equatable.dart';

import '../../domain/fee_models.dart';

/// One student in the "Collect Fee" list: what is due and what to take now.
class CollectRow extends Equatable {
  const CollectRow({
    required this.student,
    this.voucher,
    this.include = true,
    this.miscFee = 0,
    this.discount = 0,
    this.pay = 0,
  });

  final FeeStudent student;

  /// The voucher that holds the dues. Null when the student owes nothing.
  final FeeVoucher? voucher;
  final bool include;
  final int miscFee;
  final int discount;

  /// Amount to receive now.
  final int pay;

  int get total => voucher == null ? 0 : voucher!.baseTotal + miscFee - discount;
  int get balance => voucher == null ? 0 : total - voucher!.paidAmount;
  bool get canPay => voucher != null && balance > 0;

  CollectRow copyWith({bool? include, int? miscFee, int? discount, int? pay}) {
    return CollectRow(
      student: student,
      voucher: voucher,
      include: include ?? this.include,
      miscFee: miscFee ?? this.miscFee,
      discount: discount ?? this.discount,
      pay: pay ?? this.pay,
    );
  }

  @override
  List<Object?> get props => [student, voucher, include, miscFee, discount, pay];
}

enum CollectFeeStatus { initial, ready, loading, failure }

class CollectFeeState extends Equatable {
  const CollectFeeState({
    this.status = CollectFeeStatus.initial,
    this.query = '',
    this.results = const [],
    this.selected,
    this.rows = const [],
    this.history = const [],
    this.isCollecting = false,
    this.receipt,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final CollectFeeStatus status;
  final String query;

  /// Students found by the search box.
  final List<FeeStudent> results;
  final FeeStudent? selected;

  /// The selected student first, then brothers and sisters.
  final List<CollectRow> rows;

  /// All vouchers of the selected student.
  final List<FeeVoucher> history;
  final bool isCollecting;

  /// The receipt of the last payment. The page opens it for printing.
  final FeeReceipt? receipt;
  final String? errorMessage;
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  /// Sum of what will be received now.
  int get payTotal =>
      rows.where((r) => r.include && r.canPay).fold(0, (sum, r) => sum + r.pay);

  CollectFeeState copyWith({
    CollectFeeStatus? status,
    String? query,
    List<FeeStudent>? results,
    FeeStudent? Function()? selected,
    List<CollectRow>? rows,
    List<FeeVoucher>? history,
    bool? isCollecting,
    FeeReceipt? receipt,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return CollectFeeState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      selected: selected == null ? this.selected : selected(),
      rows: rows ?? this.rows,
      history: history ?? this.history,
      isCollecting: isCollecting ?? this.isCollecting,
      receipt: receipt ?? this.receipt,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        results,
        selected,
        rows,
        history,
        isCollecting,
        receipt,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
