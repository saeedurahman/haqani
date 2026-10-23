import 'package:equatable/equatable.dart';

import '../../../students/domain/student_extras.dart';
import '../../domain/fee_models.dart';

enum VouchersStatus { initial, loading, success, failure }

class VouchersState extends Equatable {
  const VouchersState({
    this.status = VouchersStatus.initial,
    this.classes = const [],
    this.classId,
    this.sectionId,
    required this.month,
    this.vouchers = const [],
    this.statusFilter,
    this.query = '',
    this.isGenerating = false,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final VouchersStatus status;
  final List<ClassOption> classes;
  final int? classId;
  final int? sectionId;

  /// `yyyy-MM`.
  final String month;
  final List<FeeVoucher> vouchers;

  /// `paid`, `partial`, `unpaid`, or null for all.
  final String? statusFilter;
  final String query;
  final bool isGenerating;
  final String? errorMessage;
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  ClassOption? get selectedClass => classes.where((c) => c.id == classId).firstOrNull;

  /// Vouchers after the status filter and the search text.
  List<FeeVoucher> get visible {
    final q = query.trim().toLowerCase();
    return vouchers.where((v) {
      if (statusFilter != null && v.status != statusFilter) return false;
      if (q.isEmpty) return true;
      return v.student.name.toLowerCase().contains(q) ||
          v.student.admissionNo.toLowerCase().contains(q) ||
          v.student.fatherName.toLowerCase().contains(q);
    }).toList();
  }

  int get totalBilled => visible.fold(0, (s, v) => s + v.total);
  int get totalCollected => visible.fold(0, (s, v) => s + v.paidAmount);
  int get totalPending => totalBilled - totalCollected;

  int count(String? status) =>
      status == null ? vouchers.length : vouchers.where((v) => v.status == status).length;

  VouchersState copyWith({
    VouchersStatus? status,
    List<ClassOption>? classes,
    int? Function()? classId,
    int? Function()? sectionId,
    String? month,
    List<FeeVoucher>? vouchers,
    String? Function()? statusFilter,
    String? query,
    bool? isGenerating,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return VouchersState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      classId: classId == null ? this.classId : classId(),
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      month: month ?? this.month,
      vouchers: vouchers ?? this.vouchers,
      statusFilter: statusFilter == null ? this.statusFilter : statusFilter(),
      query: query ?? this.query,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        classes,
        classId,
        sectionId,
        month,
        vouchers,
        statusFilter,
        query,
        isGenerating,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
