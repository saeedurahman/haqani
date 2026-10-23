import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/features/fees/data/fees_repository_impl.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';

void main() {
  late AppDatabase db;
  late FeesRepositoryImpl repo;
  late int class1;
  late int class2;
  late int ali;
  late int sara;
  var today = DateTime(2026, 5, 10);

  Future<int> addStudent(
    String no,
    String name, {
    int? cls,
    String father = '',
    String cnic = '',
    String phone = '',
    String? admitted,
    String status = 'active',
  }) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: no,
          name: name,
          classId: Value(cls),
          fatherName: Value(father),
          fatherCnic: Value(cnic),
          phone: Value(phone),
          admissionDate: Value(admitted),
          status: Value(status),
        ));
  }

  setUp(() async {
    today = DateTime(2026, 5, 10);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FeesRepositoryImpl(db, clock: () => today);
    class1 = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    class2 = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 2'));
    await repo.saveFeeStructure(class1, 1500, 3000, 2000);
    ali = await addStudent('1', 'Ali', cls: class1, admitted: '2025-04-01');
    sara = await addStudent('2', 'Sara', cls: class1, admitted: '2026-05-02');
  });

  tearDown(() => db.close());

  group('fee structure', () {
    test('lists every class, with zeros when no fee is set', () async {
      final all = await repo.getFeeStructures();

      expect(all.map((c) => c.className), ['Class 1', 'Class 2']);
      expect(all[0].monthlyFee, 1500);
      expect(all[0].annualFee, 3000);
      expect(all[0].admissionFee, 2000);
      expect(all[1].monthlyFee, 0);
    });

    test('saving again changes the fee, and negative fees are refused', () async {
      await repo.saveFeeStructure(class1, 1800, 0, 0);

      expect((await repo.getFeeStructures()).first.monthlyFee, 1800);
      expect(await db.select(db.feeStructure).get(), hasLength(1));
      expect(() => repo.saveFeeStructure(class1, -1, 0, 0), throwsA(isA<FeesException>()));
    });
  });

  group('generate vouchers', () {
    test('makes one unpaid voucher per active student with the class fee', () async {
      await addStudent('9', 'Left', cls: class1, status: 'left');

      final result = await repo.generateVouchers(classId: class1, month: '2026-04');

      expect((result.created, result.skipped), (2, 0));
      final vouchers = await repo.getVouchers(month: '2026-04', classId: class1);
      expect(vouchers.map((v) => v.student.name), ['Ali', 'Sara']);
      final v = vouchers.first;
      expect((v.monthlyFee, v.annualFee, v.admissionFee, v.previousDues), (1500, 0, 0, 0));
      expect((v.total, v.paidAmount, v.status), (1500, 0, 'unpaid'));
      expect(v.receiptNo, '');
    });

    test('annual fee only when asked, admission fee only in the admission month', () async {
      await repo.generateVouchers(classId: class1, month: '2026-05', includeAnnualFee: true);

      final vouchers = await repo.getVouchers(month: '2026-05', classId: class1);
      final aliVoucher = vouchers.firstWhere((v) => v.student.name == 'Ali');
      final saraVoucher = vouchers.firstWhere((v) => v.student.name == 'Sara');
      expect((aliVoucher.annualFee, aliVoucher.admissionFee, aliVoucher.total), (3000, 0, 4500));
      expect((saraVoucher.annualFee, saraVoucher.admissionFee, saraVoucher.total), (3000, 2000, 6500));
    });

    test('running it twice skips students who already have the month', () async {
      await repo.generateVouchers(classId: class1, month: '2026-05');

      final again = await repo.generateVouchers(classId: class1, month: '2026-05');

      expect((again.created, again.skipped), (0, 2));
      expect(await db.select(db.feeVouchers).get(), hasLength(2));
    });

    test('unpaid money of the last month is carried as previous dues', () async {
      await repo.generateVouchers(classId: class1, month: '2026-04');
      final april = (await repo.getVouchers(month: '2026-04', classId: class1)).first;
      await repo.collect([PaymentRequest(voucherId: april.id, amount: 500)], today);

      await repo.generateVouchers(classId: class1, month: '2026-05');

      final may = (await repo.getVouchers(month: '2026-05', classId: class1)).first;
      expect(may.previousDues, 1000);
      expect(may.total, 2500);
      // The April voucher is now marked as carried forward.
      final history = await repo.getHistory(ali);
      expect(history.map((v) => v.forMonth), ['2026-05', '2026-04']);
      expect(history[0].carriedForward, isFalse);
      expect(history[1].carriedForward, isTrue);
    });

    test('paying the new voucher in full clears everything; next month carries nothing', () async {
      await repo.generateVouchers(classId: class1, month: '2026-04');
      await repo.generateVouchers(classId: class1, month: '2026-05');
      final may = (await repo.getVouchers(month: '2026-05', classId: class1)).first;
      expect(may.total, 3000);

      await repo.collect([PaymentRequest(voucherId: may.id, amount: 3000)], today);
      await repo.generateVouchers(classId: class1, month: '2026-06');

      expect(await repo.getOutstanding(ali), isNotNull);
      final june = (await repo.getVouchers(month: '2026-06', classId: class1)).first;
      expect(june.previousDues, 0);
      expect(june.total, 1500);
    });

    test('refuses a class without a monthly fee, a missing class, and a student with no class', () async {
      expect(() => repo.generateVouchers(classId: class2, month: '2026-05'),
          throwsA(isA<FeesException>()));
      expect(() => repo.generateVouchers(month: '2026-05'), throwsA(isA<FeesException>()));
      final noClass = await addStudent('7', 'Nobody');
      expect(() => repo.generateVouchers(studentId: noClass, month: '2026-05'),
          throwsA(isA<FeesException>()));
    });

    test('one student only', () async {
      final result = await repo.generateVouchers(studentId: sara, month: '2026-05');

      expect(result.created, 1);
      expect(await db.select(db.feeVouchers).get(), hasLength(1));
    });

    test('a student with a later voucher is skipped, not backfilled', () async {
      await repo.generateVouchers(classId: class1, month: '2026-06');

      final result = await repo.generateVouchers(classId: class1, month: '2026-05');

      expect((result.created, result.skipped), (0, 2));
    });
  });

  group('collect', () {
    late int aliVoucher;
    late int saraVoucher;

    setUp(() async {
      await repo.generateVouchers(classId: class1, month: '2026-05');
      final vouchers = await repo.getVouchers(month: '2026-05', classId: class1);
      aliVoucher = vouchers.firstWhere((v) => v.student.name == 'Ali').id;
      saraVoucher = vouchers.firstWhere((v) => v.student.name == 'Sara').id;
    });

    test('a partial payment gives status partial and a receipt', () async {
      final receipt = await repo.collect(
        [PaymentRequest(voucherId: aliVoucher, amount: 1000)],
        today,
      );

      expect(receipt.receiptNo, '1');
      expect(receipt.date, today);
      final line = receipt.lines.single;
      expect(line.receivedNow, 1000);
      expect((line.voucher.paidAmount, line.voucher.balance, line.voucher.status),
          (1000, 500, 'partial'));
      expect(receipt.totalPaid, 1000);
      expect(receipt.totalBalance, 500);
    });

    test('paying the rest makes it paid', () async {
      await repo.collect([PaymentRequest(voucherId: aliVoucher, amount: 1000)], today);

      final receipt = await repo.collect(
        [PaymentRequest(voucherId: aliVoucher, amount: 500)],
        today,
      );

      expect(receipt.receiptNo, '2');
      expect(receipt.lines.single.voucher.status, 'paid');
      expect(await repo.getOutstanding(ali), isNull);
    });

    test('brothers and sisters share one receipt number', () async {
      final receipt = await repo.collect([
        PaymentRequest(voucherId: aliVoucher, amount: 1500),
        PaymentRequest(voucherId: saraVoucher, amount: 700),
      ], today);

      expect(receipt.lines, hasLength(2));
      expect(receipt.totalPaid, 2200);
      final fetched = await repo.getReceipt(receipt.receiptNo);
      expect(fetched!.lines.map((l) => l.voucher.student.name).toSet(), {'Ali', 'Sara'});
      expect(fetched.lines.every((l) => l.receivedNow == null), isTrue);
      expect(await db.select(db.feeVouchers).get().then((r) => r.map((v) => v.receiptNo).toSet()),
          {'1'});
    });

    test('misc fee and discount change the total', () async {
      final receipt = await repo.collect([
        PaymentRequest(voucherId: aliVoucher, amount: 1600, miscFee: 300, discount: 200),
      ], today);

      final v = receipt.lines.single.voucher;
      expect((v.miscFee, v.discount, v.total, v.status), (300, 200, 1600, 'paid'));
    });

    test('rows with 0 are ignored; nothing to receive is refused', () async {
      final receipt = await repo.collect([
        PaymentRequest(voucherId: aliVoucher, amount: 500),
        PaymentRequest(voucherId: saraVoucher, amount: 0),
      ], today);
      expect(receipt.lines, hasLength(1));

      expect(() => repo.collect([PaymentRequest(voucherId: saraVoucher, amount: 0)], today),
          throwsA(isA<FeesException>()));
      expect(() => repo.collect([], today), throwsA(isA<FeesException>()));
    });

    test('more than the balance is refused and nothing is saved', () async {
      expect(
        () => repo.collect([
          PaymentRequest(voucherId: saraVoucher, amount: 100),
          PaymentRequest(voucherId: aliVoucher, amount: 1501),
        ], today),
        throwsA(isA<FeesException>()),
      );

      final all = await db.select(db.feeVouchers).get();
      expect(all.every((v) => v.paidAmount == 0 && v.receiptNo == ''), isTrue);
    });

    test('a discount bigger than the fee is refused', () async {
      expect(
        () => repo.collect([
          PaymentRequest(voucherId: aliVoucher, amount: 1, discount: 2000),
        ], today),
        throwsA(isA<FeesException>()),
      );
    });

    test('receipt numbers keep counting up', () async {
      final a = await repo.collect([PaymentRequest(voucherId: aliVoucher, amount: 1)], today);
      final b = await repo.collect([PaymentRequest(voucherId: saraVoucher, amount: 1)], today);
      final c = await repo.collect([PaymentRequest(voucherId: aliVoucher, amount: 1)], today);

      expect([a.receiptNo, b.receiptNo, c.receiptNo], ['1', '2', '3']);
    });

    test('unknown receipt number gives null', () async {
      expect(await repo.getReceipt('99'), isNull);
    });

    test('school name and address from settings are on the receipt', () async {
      await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.settingSchoolName,
            value: 'Test School',
          ));
      final receipt = await repo.collect(
        [PaymentRequest(voucherId: aliVoucher, amount: 100)],
        today,
      );

      expect(receipt.schoolName, 'Test School');
      expect(receipt.schoolAddress, '');
    });
  });

  group('students and families', () {
    test('finds active students by name, father name and number', () async {
      await db.update(db.students).write(const StudentsCompanion(fatherName: Value('Imran')));

      expect((await repo.findStudents('ali')).single.name, 'Ali');
      expect(await repo.findStudents('imran'), hasLength(2));
      expect((await repo.findStudents('2')).single.name, 'Sara');
      expect(await repo.findStudents('  '), isEmpty);
    });

    test('family = same CNIC, or same father name and phone', () async {
      final a = await addStudent('11', 'Zoya', cls: class1, father: 'Khan', cnic: '12345-1234567-1');
      final b = await addStudent('12', 'Zayan', cls: class1, father: 'Khan', cnic: '12345-1234567-1');
      final c = await addStudent('13', 'Mina', cls: class1, father: 'Raza', phone: '0300-1111111');
      final d = await addStudent('14', 'Mira', cls: class1, father: 'raza', phone: '0300-1111111');
      await addStudent('15', 'Other', cls: class1, father: 'Raza', phone: '0300-2222222');
      await addStudent('16', 'Gone', cls: class1, father: 'Khan', cnic: '12345-1234567-1', status: 'left');

      expect((await repo.getFamily(a)).map((s) => s.name), ['Zoya', 'Zayan']);
      expect((await repo.getFamily(b)).map((s) => s.id), [b, a]);
      expect((await repo.getFamily(c)).map((s) => s.name), ['Mina', 'Mira']);
      expect((await repo.getFamily(d)).first.id, d);
    });

    test('a student without father details has no family', () async {
      expect((await repo.getFamily(ali)).map((s) => s.name), ['Ali']);
    });

    test('unknown student is refused', () async {
      expect(() => repo.getFamily(999), throwsA(isA<FeesException>()));
    });

    test('students show class and section in the label', () async {
      final sec = await db.into(db.sections).insert(SectionsCompanion.insert(classId: class1, name: 'A'));
      await (db.update(db.students)..where((t) => t.id.equals(ali)))
          .write(StudentsCompanion(sectionId: Value(sec)));

      expect((await repo.findStudents('ali')).single.classLabel, 'Class 1 - A');
      expect((await repo.findStudents('sara')).single.classLabel, 'Class 1');
    });
  });

  test('outstanding is the newest voucher while it has a balance', () async {
    expect(await repo.getOutstanding(ali), isNull);

    await repo.generateVouchers(classId: class1, month: '2026-05');

    final due = await repo.getOutstanding(ali);
    expect(due!.balance, 1500);
    expect(due.forMonth, '2026-05');
  });
}
