import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/fees/data/fees_repository_impl.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fee_migration');
    file = File(p.join(dir.path, 'school.db'));
    await _writeVersion1(file);
  });

  tearDown(() async => dir.delete(recursive: true));

  AppDatabase open() {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    return db;
  }

  test(
    'version 2 moves the money on vouchers into fee_payments, losing nothing',
    () async {
      final db = open();

      final payments = await (db.select(
        db.feePayments,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(
        payments.map(
          (r) => (r.voucherId, r.receiptNo, r.date, r.amount, r.note),
        ),
        [
          (1, '7', '2026-05-10', 1500, ''),
          (2, '7', '2026-05-10', 1500, ''),
          (3, '9', '2026-06-12', 600, ''),
        ],
      );

      // Totals, paid amounts and status are untouched; the old receipt column is cleared.
      final vouchers = await (db.select(
        db.feeVouchers,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(
        vouchers.map(
          (v) => (v.id, v.total, v.paidAmount, v.status, v.receiptNo),
        ),
        [
          (1, 1500, 1500, 'paid', ''),
          (2, 1500, 1500, 'paid', ''),
          (3, 1500, 600, 'partial', ''),
          (4, 1500, 0, 'unpaid', ''),
        ],
      );
      for (final v in vouchers) {
        final sum = payments
            .where((r) => r.voucherId == v.id)
            .fold<int>(0, (s, r) => s + r.amount);
        expect(sum, v.paidAmount, reason: 'voucher ${v.id}');
      }
    },
  );

  test('old receipts can still be printed, and new receipts continue the numbering', () async {
    final repo = FeesRepositoryImpl(open(), clock: () => DateTime(2026, 6, 20));

    final sisters = (await repo.getReceipt('7'))!;
    expect(sisters.date, DateTime(2026, 5, 10));
    expect(sisters.lines.map((l) => l.voucher.student.name), ['Ali', 'Sara']);
    expect(sisters.lines.map((l) => l.receivedNow), [1500, 1500]);

    final partly = (await repo.getReceipt('9'))!.lines.single;
    expect(
      (partly.receivedNow, partly.voucher.paidAmount, partly.voucher.balance),
      (600, 600, 900),
    );

    final next = await repo.collect([
      const PaymentRequest(voucherId: 3, amount: 900),
    ], DateTime(2026, 6, 20));
    expect(next.receiptNo, '10');
    expect((await repo.getReceipt('9'))!.lines.single.voucher.paidAmount, 600);
    expect((await repo.getHistory(1)).first.receiptNos, '9, 10');
  });

  test(
    'opening the upgraded file again does not copy the payments twice',
    () async {
      final first = open();
      expect((await first.select(first.feePayments).get()), hasLength(3));
      await first.close();

      final second = open();
      expect((await second.select(second.feePayments).get()), hasLength(3));
    },
  );

  test('a new database starts with no payments', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
    expect(await db.select(db.feePayments).get(), isEmpty);
  });
}

/// Builds a file shaped like a version 1 database: no fee_payments table, and
/// the receipt number and date of the last payment stored on the voucher.
/// Two sisters (Ali, Sara) share receipt 7; Ali paid part of June on receipt 9.
Future<void> _writeVersion1(File file) async {
  final db = AppDatabase.forTesting(NativeDatabase(file));
  final classId = await db
      .into(db.schoolClasses)
      .insert(SchoolClassesCompanion.insert(name: 'Class 1'));
  Future<int> student(String no, String name) => db
      .into(db.students)
      .insert(
        StudentsCompanion.insert(
          admissionNo: no,
          name: name,
          classId: Value(classId),
        ),
      );
  final ali = await student('1', 'Ali');
  final sara = await student('2', 'Sara');

  Future<void> voucher(
    int id,
    String receipt,
    String date,
    int studentId,
    String month,
    int paid,
  ) {
    return db
        .into(db.feeVouchers)
        .insert(
          FeeVouchersCompanion.insert(
            id: Value(id),
            receiptNo: receipt,
            date: date,
            studentId: studentId,
            forMonth: month,
            monthlyFee: const Value(1500),
            total: const Value(1500),
            paidAmount: Value(paid),
            status: Value(FeeStatus.of(1500, paid)),
          ),
        );
  }

  await voucher(1, '7', '2026-05-10', ali, '2026-05', 1500);
  await voucher(2, '7', '2026-05-10', sara, '2026-05', 1500);
  await voucher(3, '9', '2026-06-12', ali, '2026-06', 600);
  await voucher(4, '', '2026-06-01', sara, '2026-06', 0);

  await db.customStatement('DROP TABLE fee_payments');
  await db.customStatement('PRAGMA user_version = 1');
  await db.close();
}
