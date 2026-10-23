import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/fee_models.dart';
import '../../domain/fees_repository.dart';
import 'collect_fee_state.dart';

/// Find a student, see what the student (and brothers and sisters) owe,
/// take the money and get one receipt.
class CollectFeeCubit extends Cubit<CollectFeeState> {
  CollectFeeCubit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const CollectFeeState(status: CollectFeeStatus.ready));

  final FeesRepository _repository;
  final DateTime Function() _clock;
  int _request = 0;

  Future<void> search(String query) async {
    final id = ++_request;
    emit(state.copyWith(query: query));
    try {
      final results = await _repository.findStudents(query);
      if (id != _request) return;
      emit(state.copyWith(results: results));
    } catch (_) {
      if (id == _request) _fail();
    }
  }

  Future<void> selectStudent(FeeStudent student) async {
    emit(state.copyWith(
      status: CollectFeeStatus.loading,
      selected: () => student,
      note: '',
      rows: const [],
      history: const [],
    ));
    await _loadSelected(student);
  }

  /// Goes back to the search box.
  void clearSelection() {
    emit(state.copyWith(selected: () => null, note: '', rows: const [], history: const []));
  }

  void setNote(String note) => emit(state.copyWith(note: note));

  void setInclude(int studentId, bool include) => _changeRow(studentId, (r) => r.copyWith(include: include));

  /// Clamped between 0 and the balance.
  void setPay(int studentId, int amount) {
    _changeRow(studentId, (r) => r.copyWith(pay: amount.clamp(0, r.balance)));
  }

  /// Extra charge. The amount to receive goes back to the full balance.
  void setMiscFee(int studentId, int amount) {
    _changeRow(studentId, (r) {
      final changed = r.copyWith(miscFee: amount < 0 ? 0 : amount);
      return changed.copyWith(pay: changed.balance);
    });
  }

  /// Discount. It cannot be more than what is left to pay.
  void setDiscount(int studentId, int amount) {
    _changeRow(studentId, (r) {
      final paid = r.voucher?.paidAmount ?? 0;
      final most = r.voucher == null ? 0 : r.voucher!.baseTotal + r.miscFee - paid;
      final changed = r.copyWith(discount: amount.clamp(0, most));
      return changed.copyWith(pay: changed.balance);
    });
  }

  /// Makes this month's voucher for a student who owes nothing yet.
  Future<void> createVoucher(FeeStudent student) async {
    try {
      final result = await _repository.generateVouchers(
        studentId: student.id,
        month: AppDateUtils.toMonth(_clock()),
      );
      await _loadSelected(state.selected ?? student);
      _notify(
        result.created > 0 ? 'Voucher created.' : 'A voucher for this month already exists.',
        isError: false,
      );
    } on FeesException catch (e) {
      _notify(e.message, isError: true);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true);
    }
  }

  Future<void> collect() async {
    final selected = state.selected;
    if (selected == null || state.isCollecting) return;
    final payments = [
      for (final r in state.rows)
        if (r.include && r.canPay && r.pay > 0)
          PaymentRequest(
            voucherId: r.voucher!.id,
            amount: r.pay,
            miscFee: r.miscFee,
            discount: r.discount,
            note: state.note,
          ),
    ];
    emit(state.copyWith(isCollecting: true));
    try {
      final receipt = await _repository.collect(payments, _clock());
      await _loadSelected(selected);
      emit(state.copyWith(
        isCollecting: false,
        note: '',
        receipt: receipt,
        feedback: 'Fee received. Receipt No ${receipt.receiptNo}.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on FeesException catch (e) {
      emit(state.copyWith(isCollecting: false));
      _notify(e.message, isError: true);
    } catch (_) {
      emit(state.copyWith(isCollecting: false));
      _notify(AppStrings.somethingWentWrong, isError: true);
    }
  }

  Future<void> _loadSelected(FeeStudent student) async {
    try {
      final family = await _repository.getFamily(student.id);
      final rows = <CollectRow>[];
      for (final member in family) {
        final voucher = await _repository.getOutstanding(member.id);
        rows.add(voucher == null
            ? CollectRow(student: member, include: false)
            : CollectRow(
                student: member,
                voucher: voucher,
                miscFee: voucher.miscFee,
                discount: voucher.discount,
                pay: voucher.balance,
              ));
      }
      final history = await _repository.getHistory(student.id);
      emit(state.copyWith(status: CollectFeeStatus.ready, rows: rows, history: history));
    } catch (_) {
      _fail();
    }
  }

  void _changeRow(int studentId, CollectRow Function(CollectRow) change) {
    emit(state.copyWith(rows: [
      for (final r in state.rows) r.student.id == studentId ? change(r) : r,
    ]));
  }

  void _notify(String message, {required bool isError}) {
    emit(state.copyWith(
      feedback: message,
      feedbackIsError: isError,
      feedbackId: state.feedbackId + 1,
    ));
  }

  void _fail() {
    emit(state.copyWith(
      status: CollectFeeStatus.failure,
      errorMessage: AppStrings.somethingWentWrong,
    ));
  }
}
