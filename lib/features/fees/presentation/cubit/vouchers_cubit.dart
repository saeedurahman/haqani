import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/fee_models.dart';
import '../../domain/fees_repository.dart';
import 'vouchers_state.dart';

/// Monthly vouchers of a class: make them, and see who paid and who did not.
class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(VouchersState(month: AppDateUtils.toMonth((clock ?? DateTime.now)())));

  final FeesRepository _repository;
  final DateTime Function() _clock;
  int _request = 0;

  Future<void> load() async {
    emit(state.copyWith(status: VouchersStatus.loading));
    try {
      final classes = await _repository.getClassOptions();
      emit(state.copyWith(
        classes: classes,
        classId: () => classes.isEmpty ? null : classes.first.id,
        sectionId: () => null,
      ));
      await _loadVouchers();
    } catch (_) {
      _fail();
    }
  }

  Future<void> selectClass(int? classId) {
    emit(state.copyWith(classId: () => classId, sectionId: () => null));
    return _loadVouchers();
  }

  Future<void> selectSection(int? sectionId) {
    emit(state.copyWith(sectionId: () => sectionId));
    return _loadVouchers();
  }

  /// Moves the month. Next month is the furthest allowed.
  Future<void> moveMonth(int months) {
    final current = DateTime.parse('${state.month}-01');
    final next = DateTime(current.year, current.month + months);
    final now = _clock();
    if (next.isAfter(DateTime(now.year, now.month + 1))) return Future.value();
    emit(state.copyWith(month: AppDateUtils.toMonth(next)));
    return _loadVouchers();
  }

  void filterByStatus(String? status) => emit(state.copyWith(statusFilter: () => status));

  void search(String query) => emit(state.copyWith(query: query));

  /// Reloads the list, for example after a payment on another tab.
  Future<void> refresh() => _loadVouchers();

  Future<void> generate({bool includeAnnualFee = false}) async {
    final classId = state.classId;
    if (classId == null || state.isGenerating) return;
    emit(state.copyWith(isGenerating: true));
    try {
      final result = await _repository.generateVouchers(
        classId: classId,
        sectionId: state.sectionId,
        month: state.month,
        includeAnnualFee: includeAnnualFee,
      );
      final vouchers = await _repository.getVouchers(
        month: state.month,
        classId: classId,
        sectionId: state.sectionId,
      );
      emit(state.copyWith(
        isGenerating: false,
        vouchers: vouchers,
        feedback: _summary(result),
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on FeesException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  String _summary(GenerationResult r) {
    if (r.created == 0 && r.skipped > 0) {
      return 'Nothing new. ${r.skipped} students already have a voucher.';
    }
    final made = r.created == 1 ? '1 voucher created.' : '${r.created} vouchers created.';
    return r.skipped == 0 ? made : '$made ${r.skipped} skipped (already have one).';
  }

  Future<void> _loadVouchers() async {
    final classId = state.classId;
    if (classId == null) {
      emit(state.copyWith(status: VouchersStatus.success, vouchers: const []));
      return;
    }
    final id = ++_request;
    emit(state.copyWith(status: VouchersStatus.loading));
    try {
      final vouchers = await _repository.getVouchers(
        month: state.month,
        classId: classId,
        sectionId: state.sectionId,
      );
      if (id != _request) return;
      emit(state.copyWith(status: VouchersStatus.success, vouchers: vouchers));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(
      isGenerating: false,
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }

  void _fail() {
    emit(state.copyWith(
      status: VouchersStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
