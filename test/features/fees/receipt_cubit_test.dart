import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/services/whatsapp_service.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:haqani/features/fees/domain/fees_repository.dart';
import 'package:haqani/features/fees/domain/receipt_pdf_service.dart';
import 'package:haqani/features/fees/presentation/cubit/receipt_cubit.dart';
import 'package:haqani/features/fees/presentation/cubit/receipt_state.dart';
import 'package:haqani/features/students/domain/student_extras.dart';

import '../../support/fake_whatsapp.dart';

FeeVoucher _voucher(int id, String name, {int total = 1500, int paid = 1500}) => FeeVoucher(
      id: id,
      date: DateTime(2026, 5, 10),
      student: FeeStudent(id: id, name: name, admissionNo: '$id'),
      forMonth: '2026-05',
      monthlyFee: total,
      total: total,
      paidAmount: paid,
      status: FeeStatus.of(total, paid),
    );

FeeReceipt _receipt(List<ReceiptLine> lines) => FeeReceipt(
      receiptNo: '12',
      date: DateTime(2026, 5, 10),
      schoolName: 'Test',
      schoolAddress: '',
      lines: lines,
    );

class _FakeRepository implements FeesRepository {
  FeeReceipt? stored;

  @override
  Future<FeeReceipt?> getReceipt(String receiptNo) async => stored;

  @override
  Future<List<ClassOption>> getClassOptions() async => const [];
  @override
  Future<List<ClassFee>> getFeeStructures() async => const [];
  @override
  Future<void> saveFeeStructure(int classId, int monthly, int annual, int admission) async {}
  @override
  Future<List<FeeStudent>> findStudents(String query) async => const [];
  @override
  Future<List<FeeStudent>> getFamily(int studentId) async => const [];
  @override
  Future<FeeVoucher?> getOutstanding(int studentId) async => null;
  @override
  Future<List<FeeVoucher>> getHistory(int studentId) async => const [];
  @override
  Future<GenerationResult> generateVouchers({
    int? classId,
    int? sectionId,
    int? studentId,
    required String month,
    bool includeAnnualFee = false,
  }) async =>
      const GenerationResult(created: 0, skipped: 0);
  @override
  Future<List<FeeVoucher>> getVouchers({required String month, required int classId, int? sectionId}) async =>
      const [];
  @override
  Future<List<Defaulter>> getDefaulters({int? classId}) async => const [];
  @override
  Future<FeeReceipt> collect(List<PaymentRequest> payments, DateTime date) async => throw UnimplementedError();
}

class _FakePdf implements ReceiptPdfService {
  @override
  Future<Uint8List> build(FeeReceipt receipt) async => Uint8List.fromList([1]);
}

void main() {
  late _FakeRepository repo;
  late FakeWhatsAppService whatsApp;

  setUp(() {
    repo = _FakeRepository();
    whatsApp = FakeWhatsAppService();
  });

  test('load builds the receipt PDF', () async {
    repo.stored = _receipt([ReceiptLine(voucher: _voucher(1, 'Ali'))]);
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);

    await cubit.load(receiptNo: '12');

    expect(cubit.state.status, ReceiptStatus.success);
    expect(cubit.state.pdfBytes, isNotNull);
    await cubit.close();
  });

  test('an unknown receipt number fails with a clear message', () async {
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);

    await cubit.load(receiptNo: '99');

    expect(cubit.state.status, ReceiptStatus.failure);
    expect(cubit.state.errorMessage, 'This receipt was not found.');
    await cubit.close();
  });

  test('WhatsApp message for one student with a balance', () async {
    final receipt = _receipt([
      ReceiptLine(voucher: _voucher(1, 'Ali', total: 2500, paid: 1500), receivedNow: 1500),
    ]);
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);
    await cubit.load(receipt: receipt);

    await cubit.sendWhatsApp();

    expect(whatsApp.sent.single.studentId, 1);
    final body = whatsApp.sent.single.body;
    expect(body, contains('fee of Rs 1,500 for Ali on 10 May 2026'));
    expect(body, contains('Receipt No: 12'));
    expect(body, contains('Balance still to pay: Rs 1,000'));
    expect(cubit.state.feedback, contains('WhatsApp opened'));
    await cubit.close();
  });

  test('sisters on one receipt: one message to the first student\'s parent with the total', () async {
    final receipt = _receipt([
      ReceiptLine(voucher: _voucher(1, 'Ayesha'), receivedNow: 1500),
      ReceiptLine(voucher: _voucher(2, 'Sara'), receivedNow: 1500),
    ]);
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);
    await cubit.load(receipt: receipt);

    await cubit.sendWhatsApp();

    expect(whatsApp.sent, hasLength(1));
    expect(whatsApp.sent.single.studentId, 1);
    expect(whatsApp.sent.single.body, contains('Rs 3,000 for Ayesha, Sara'));
    expect(whatsApp.sent.single.body, contains('No balance is pending'));
    await cubit.close();
  });

  test('an old receipt (nothing "received now") uses what was paid', () async {
    repo.stored = _receipt([ReceiptLine(voucher: _voucher(1, 'Ali', paid: 1000))]);
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);
    await cubit.load(receiptNo: '12');

    await cubit.sendWhatsApp();

    expect(whatsApp.sent.single.body, contains('Rs 1,000'));
    await cubit.close();
  });

  test('nothing is sent before the receipt is loaded, and a missing number shows the reason', () async {
    final cubit = ReceiptCubit(repo, _FakePdf(), whatsApp);
    await cubit.sendWhatsApp();
    expect(whatsApp.sent, isEmpty);

    whatsApp.result = WhatsAppResult.noNumber;
    await cubit.load(receipt: _receipt([ReceiptLine(voucher: _voucher(1, 'Ali'))]));
    await cubit.sendWhatsApp();
    expect(cubit.state.feedbackIsError, isTrue);
    expect(cubit.state.feedback, contains('No valid phone number'));
    await cubit.close();
  });
}
