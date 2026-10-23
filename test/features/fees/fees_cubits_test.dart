import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_whatsapp.dart';
import 'package:haqani/core/services/whatsapp_service.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:haqani/features/fees/domain/fees_repository.dart';
import 'package:haqani/features/fees/presentation/cubit/collect_fee_cubit.dart';
import 'package:haqani/features/fees/presentation/cubit/collect_fee_state.dart';
import 'package:haqani/features/fees/presentation/cubit/fee_structure_cubit.dart';
import 'package:haqani/features/fees/presentation/cubit/fee_structure_state.dart';
import 'package:haqani/features/fees/presentation/cubit/vouchers_cubit.dart';
import 'package:haqani/features/fees/presentation/cubit/vouchers_state.dart';
import 'package:haqani/features/students/domain/student_extras.dart';

const _ali = FeeStudent(id: 1, name: 'Ali', admissionNo: '1', fatherName: 'Raza', classLabel: 'Class 1');
const _sara = FeeStudent(id: 2, name: 'Sara', admissionNo: '2', fatherName: 'Raza', classLabel: 'Class 3');

FeeVoucher _voucher(FeeStudent s, {int id = 1, int paid = 0, int previous = 0, int misc = 0}) {
  const monthly = 1500;
  final total = monthly + previous + misc;
  return FeeVoucher(
    id: id,
    receiptNo: '',
    date: DateTime(2026, 5, 1),
    student: s,
    forMonth: '2026-05',
    monthlyFee: monthly,
    previousDues: previous,
    miscFee: misc,
    total: total,
    paidAmount: paid,
    status: FeeStatus.of(total, paid),
  );
}

class _FakeRepository implements FeesRepository {
  bool fail = false;
  String? blockWith;
  List<ClassFee> fees = const [
    ClassFee(classId: 1, className: 'Class 1', monthlyFee: 1500),
    ClassFee(classId: 2, className: 'Class 2'),
  ];
  List<FeeStudent> found = const [_ali];
  List<FeeStudent> family = const [_ali, _sara];
  Map<int, FeeVoucher?> outstanding = {
    1: _voucher(_ali, id: 10),
    2: null,
  };
  List<FeeVoucher> history = const [];
  List<FeeVoucher> vouchers = const [];
  String? lastMonth;
  bool? lastAnnual;
  int? lastClassId;
  int? lastStudentId;
  List<PaymentRequest>? lastPayments;
  GenerationResult generation = const GenerationResult(created: 2, skipped: 0);
  (int, int, int, int)? savedFee;

  void _check() {
    if (fail) throw Exception('db');
    if (blockWith != null) throw FeesException(blockWith!);
  }

  @override
  Future<List<ClassOption>> getClassOptions() async {
    _check();
    return const [ClassOption(id: 1, name: 'Class 1'), ClassOption(id: 2, name: 'Class 2')];
  }

  @override
  Future<List<ClassFee>> getFeeStructures() async {
    if (fail) throw Exception('db');
    return fees;
  }

  @override
  Future<void> saveFeeStructure(int classId, int monthly, int annual, int admission) async {
    _check();
    savedFee = (classId, monthly, annual, admission);
    fees = [
      for (final f in fees)
        f.classId == classId
            ? ClassFee(classId: classId, className: f.className, monthlyFee: monthly, annualFee: annual, admissionFee: admission)
            : f,
    ];
  }

  @override
  Future<List<FeeStudent>> findStudents(String query) async {
    if (fail) throw Exception('db');
    return found;
  }

  @override
  Future<List<FeeStudent>> getFamily(int studentId) async {
    if (fail) throw Exception('db');
    return family;
  }

  @override
  Future<FeeVoucher?> getOutstanding(int studentId) async => outstanding[studentId];

  @override
  Future<List<FeeVoucher>> getHistory(int studentId) async => history;

  @override
  Future<GenerationResult> generateVouchers({
    int? classId,
    int? sectionId,
    int? studentId,
    required String month,
    bool includeAnnualFee = false,
  }) async {
    _check();
    lastClassId = classId;
    lastStudentId = studentId;
    lastMonth = month;
    lastAnnual = includeAnnualFee;
    return generation;
  }

  @override
  Future<List<FeeVoucher>> getVouchers({required String month, required int classId, int? sectionId}) async {
    if (fail) throw Exception('db');
    lastMonth = month;
    lastClassId = classId;
    return vouchers;
  }

  @override
  Future<List<Defaulter>> getDefaulters({int? classId}) async => const [];

  @override
  Future<FeeReceipt> collect(List<PaymentRequest> payments, DateTime date) async {
    _check();
    lastPayments = payments;
    return FeeReceipt(
      receiptNo: '7',
      date: date,
      schoolName: 'Test',
      schoolAddress: '',
      lines: [for (final p in payments) ReceiptLine(voucher: _voucher(_ali, id: p.voucherId, paid: p.amount), receivedNow: p.amount)],
    );
  }

  @override
  Future<FeeReceipt?> getReceipt(String receiptNo) async => null;
}

void main() {
  final now = DateTime(2026, 5, 12);
  late _FakeRepository repo;

  late FakeWhatsAppService whatsApp;

  setUp(() {
    repo = _FakeRepository();
    whatsApp = FakeWhatsAppService();
  });

  group('FeeStructureCubit', () {
    test('load, then save shows the class name and the new fee', () async {
      final cubit = FeeStructureCubit(repo);
      await cubit.load();
      expect(cubit.state.status, FeeStructureStatus.success);
      expect(cubit.state.fees, hasLength(2));

      await cubit.save(2, monthly: 1800, annual: 3000, admission: 500);

      expect(repo.savedFee, (2, 1800, 3000, 500));
      expect(cubit.state.feedback, 'Fees saved for Class 2.');
      expect(cubit.state.fees.last.monthlyFee, 1800);
      await cubit.close();
    });

    test('a refused save and a load failure are friendly', () async {
      final cubit = FeeStructureCubit(repo);
      await cubit.load();
      repo.blockWith = 'Fees cannot be less than 0.';

      await cubit.save(1, monthly: -1, annual: 0, admission: 0);
      expect(cubit.state.feedback, 'Fees cannot be less than 0.');
      expect(cubit.state.feedbackIsError, isTrue);

      repo.fail = true;
      await cubit.load();
      expect(cubit.state.status, FeeStructureStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('VouchersCubit', () {
    VouchersCubit make() => VouchersCubit(repo, whatsApp, clock: () => now);

    test('load starts on the current month and the first class', () async {
      repo.vouchers = [_voucher(_ali)];
      final cubit = make();

      await cubit.load();

      expect(cubit.state.month, '2026-05');
      expect(cubit.state.classId, 1);
      expect(repo.lastMonth, '2026-05');
      expect(cubit.state.vouchers, hasLength(1));
      await cubit.close();
    });

    test('totals, status filter and search', () async {
      repo.vouchers = [
        _voucher(_ali, id: 1, paid: 1500),
        _voucher(_sara, id: 2, paid: 500),
        _voucher(const FeeStudent(id: 3, name: 'Zain', admissionNo: '3'), id: 3),
      ];
      final cubit = make();
      await cubit.load();

      expect(cubit.state.totalBilled, 4500);
      expect(cubit.state.totalCollected, 2000);
      expect(cubit.state.totalPending, 2500);
      expect(cubit.state.count(null), 3);
      expect(cubit.state.count(FeeStatus.partial), 1);

      cubit.filterByStatus(FeeStatus.unpaid);
      expect(cubit.state.visible.map((v) => v.student.name), ['Zain']);
      expect(cubit.state.totalPending, 1500);

      cubit.filterByStatus(null);
      cubit.search('sar');
      expect(cubit.state.visible.map((v) => v.student.name), ['Sara']);
      await cubit.close();
    });

    test('moving the month reloads; the furthest is next month', () async {
      final cubit = make();
      await cubit.load();

      await cubit.moveMonth(-1);
      expect(cubit.state.month, '2026-04');
      expect(repo.lastMonth, '2026-04');

      await cubit.moveMonth(1);
      await cubit.moveMonth(1);
      expect(cubit.state.month, '2026-06');
      await cubit.moveMonth(1);
      expect(cubit.state.month, '2026-06', reason: 'no further than next month');
      await cubit.close();
    });

    test('moving back over New Year works', () async {
      final cubit = VouchersCubit(repo, whatsApp, clock: () => DateTime(2026, 1, 5));
      await cubit.load();

      await cubit.moveMonth(-1);

      expect(cubit.state.month, '2025-12');
      await cubit.close();
    });

    test('generate passes the options and reports what happened', () async {
      final cubit = make();
      await cubit.load();

      await cubit.generate(includeAnnualFee: true);

      expect(repo.lastAnnual, isTrue);
      expect(cubit.state.feedback, '2 vouchers created.');
      expect(cubit.state.isGenerating, isFalse);

      repo.generation = const GenerationResult(created: 1, skipped: 3);
      await cubit.generate();
      expect(cubit.state.feedback, '1 voucher created. 3 skipped (already have one).');

      repo.generation = const GenerationResult(created: 0, skipped: 4);
      await cubit.generate();
      expect(cubit.state.feedback, 'Nothing new. 4 students already have a voucher.');
      await cubit.close();
    });

    test('generate shows the rule when it is refused', () async {
      final cubit = make();
      await cubit.load();
      repo.blockWith = 'Set the monthly fee for Class 1 first (Fee Structure tab).';

      await cubit.generate();

      expect(cubit.state.feedback, repo.blockWith);
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.isGenerating, isFalse);
      await cubit.close();
    });

    test('load failure is friendly', () async {
      repo.fail = true;
      final cubit = make();

      await cubit.load();

      expect(cubit.state.status, VouchersStatus.failure);
      await cubit.close();
    });
  });

  group('CollectFeeCubit', () {
    CollectFeeCubit make() => CollectFeeCubit(repo, clock: () => now);

    test('search finds students', () async {
      final cubit = make();

      await cubit.search('ali');

      expect(cubit.state.results.single.name, 'Ali');
      await cubit.close();
    });

    test('selecting a student lists the family with dues, pay defaults to the balance', () async {
      final cubit = make();

      await cubit.selectStudent(_ali);

      expect(cubit.state.status, CollectFeeStatus.ready);
      expect(cubit.state.rows.map((r) => r.student.name), ['Ali', 'Sara']);
      final ali = cubit.state.rows[0];
      final sara = cubit.state.rows[1];
      expect((ali.include, ali.canPay, ali.balance, ali.pay), (true, true, 1500, 1500));
      expect((sara.include, sara.canPay, sara.balance), (false, false, 0));
      expect(cubit.state.payTotal, 1500);
      await cubit.close();
    });

    test('pay is held between 0 and the balance', () async {
      final cubit = make();
      await cubit.selectStudent(_ali);

      cubit.setPay(1, 600);
      expect(cubit.state.rows[0].pay, 600);
      expect(cubit.state.payTotal, 600);

      cubit.setPay(1, 99999);
      expect(cubit.state.rows[0].pay, 1500);
      cubit.setPay(1, -5);
      expect(cubit.state.rows[0].pay, 0);
      await cubit.close();
    });

    test('misc fee raises the balance, discount lowers it and cannot pass what is left', () async {
      final cubit = make();
      await cubit.selectStudent(_ali);

      cubit.setMiscFee(1, 200);
      expect((cubit.state.rows[0].total, cubit.state.rows[0].pay), (1700, 1700));

      cubit.setDiscount(1, 300);
      expect((cubit.state.rows[0].total, cubit.state.rows[0].pay), (1400, 1400));

      cubit.setDiscount(1, 999999);
      expect(cubit.state.rows[0].discount, 1700, reason: 'cannot be more than the fee');
      expect(cubit.state.rows[0].pay, 0);
      await cubit.close();
    });

    test('unticked students are not charged', () async {
      repo.outstanding = {1: _voucher(_ali, id: 10), 2: _voucher(_sara, id: 20)};
      final cubit = make();
      await cubit.selectStudent(_ali);
      expect(cubit.state.payTotal, 3000);

      cubit.setInclude(2, false);

      expect(cubit.state.payTotal, 1500);
      await cubit.close();
    });

    test('collect sends one payment per ticked student and opens the receipt', () async {
      repo.outstanding = {1: _voucher(_ali, id: 10), 2: _voucher(_sara, id: 20)};
      final cubit = make();
      await cubit.selectStudent(_ali);
      cubit.setPay(2, 700);
      cubit.setMiscFee(1, 100);

      await cubit.collect();

      expect(repo.lastPayments, [
        const PaymentRequest(voucherId: 10, amount: 1600, miscFee: 100),
        const PaymentRequest(voucherId: 20, amount: 700),
      ]);
      expect(cubit.state.receipt?.receiptNo, '7');
      expect(cubit.state.feedback, 'Fee received. Receipt No 7.');
      expect(cubit.state.feedbackIsError, isFalse);
      expect(cubit.state.isCollecting, isFalse);
      await cubit.close();
    });

    test('a refused payment shows the reason and keeps the screen', () async {
      final cubit = make();
      await cubit.selectStudent(_ali);
      repo.blockWith = 'The amount is more than the balance.';

      await cubit.collect();

      expect(cubit.state.feedback, 'The amount is more than the balance.');
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.isCollecting, isFalse);
      expect(cubit.state.receipt, isNull);
      expect(cubit.state.rows, isNotEmpty);
      await cubit.close();
    });

    test('create voucher makes this month\'s voucher for the student', () async {
      final cubit = make();
      await cubit.selectStudent(_ali);

      await cubit.createVoucher(_sara);

      expect(repo.lastStudentId, 2);
      expect(repo.lastMonth, '2026-05');
      expect(cubit.state.feedback, 'Voucher created.');
      await cubit.close();
    });

    test('clearing the selection goes back to search', () async {
      final cubit = make();
      await cubit.selectStudent(_ali);

      cubit.clearSelection();

      expect(cubit.state.selected, isNull);
      expect(cubit.state.rows, isEmpty);
      await cubit.close();
    });

    test('a database error on select is friendly', () async {
      repo.fail = true;
      final cubit = make();

      await cubit.selectStudent(_ali);

      expect(cubit.state.status, CollectFeeStatus.failure);
      await cubit.close();
    });
  });

  group('VouchersCubit WhatsApp', () {
    test('sends a fee reminder to the parent of the voucher', () async {
      final cubit = VouchersCubit(repo, whatsApp, clock: () => now);

      await cubit.remind(_voucher(_ali, paid: 500));

      expect(whatsApp.sent.single.studentId, 1);
      expect(whatsApp.sent.single.body, contains('reminder'));
      expect(whatsApp.sent.single.body, contains('Ali'));
      expect(whatsApp.sent.single.body, contains('May 2026'));
      expect(whatsApp.sent.single.body, contains('Balance: Rs 1,000'));
      expect(cubit.state.feedback, contains('WhatsApp opened'));
      await cubit.close();
    });

    test('shows why it could not open WhatsApp', () async {
      whatsApp.result = WhatsAppResult.failed;
      final cubit = VouchersCubit(repo, whatsApp, clock: () => now);

      await cubit.remind(_voucher(_ali));

      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.feedback, contains('could not be opened'));
      await cubit.close();
    });
  });
}
