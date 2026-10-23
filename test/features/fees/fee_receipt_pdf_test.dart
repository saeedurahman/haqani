import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/fees/data/fee_receipt_pdf.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';

FeeVoucher _voucher(String name, int id, {int paid = 1500, int misc = 0, int annual = 0}) {
  final total = 1500 + annual + misc;
  return FeeVoucher(
    id: id,
    date: DateTime(2026, 5, 10),
    student: FeeStudent(
      id: id,
      name: name,
      admissionNo: '$id',
      registrationNo: 'R-$id',
      classLabel: 'Class 1 - A',
    ),
    forMonth: '2026-05',
    monthlyFee: 1500,
    annualFee: annual,
    miscFee: misc,
    total: total,
    paidAmount: paid,
    status: FeeStatus.of(total, paid),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FeeReceipt receipt(List<FeeVoucher> vouchers) => FeeReceipt(
        receiptNo: '12',
        date: DateTime(2026, 5, 10),
        schoolName: 'Rozatul Atfal',
        schoolAddress: 'Lahore',
        lines: [for (final v in vouchers) ReceiptLine(voucher: v, receivedNow: v.paidAmount)],
      );

  test('builds a PDF for one student', () async {
    final bytes = await FeeReceiptPdf().build(receipt([_voucher('Ali Raza', 1)]));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(3000));
  });

  test('builds a PDF for three brothers and sisters, with Urdu names and a partial payment', () async {
    final bytes = await FeeReceiptPdf().build(receipt([
      _voucher('Ali Raza', 1),
      _voucher('عائشہ خان', 2, paid: 700, misc: 200),
      _voucher('Sara Raza', 3, annual: 3000),
    ]));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['RECEIPT_SAMPLE_PATH'];
    if (path == null) return;
    File(path).writeAsBytesSync(await FeeReceiptPdf().build(receipt([
      _voucher('Ali Raza', 1),
      _voucher('عائشہ خان', 2, paid: 700, misc: 200),
    ])));
  });
}
