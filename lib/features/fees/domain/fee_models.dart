import 'package:equatable/equatable.dart';

/// Thrown with a message that is safe to show to the user.
class FeesException implements Exception {
  const FeesException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FeeStatus {
  const FeeStatus._();

  static const paid = 'paid';
  static const partial = 'partial';
  static const unpaid = 'unpaid';

  static String label(String status) => switch (status) {
        paid => 'Paid',
        partial => 'Partial',
        _ => 'Unpaid',
      };

  /// Status from the amounts. A voucher of 0 is paid.
  static String of(int total, int paidAmount) {
    if (paidAmount >= total) return paid;
    return paidAmount > 0 ? partial : unpaid;
  }
}

/// The monthly, annual and admission fee of one class.
class ClassFee extends Equatable {
  const ClassFee({
    required this.classId,
    required this.className,
    this.monthlyFee = 0,
    this.annualFee = 0,
    this.admissionFee = 0,
  });

  final int classId;
  final String className;
  final int monthlyFee;
  final int annualFee;
  final int admissionFee;

  @override
  List<Object?> get props => [classId, className, monthlyFee, annualFee, admissionFee];
}

/// A student as shown on the fee screens.
class FeeStudent extends Equatable {
  const FeeStudent({
    required this.id,
    required this.name,
    required this.admissionNo,
    this.registrationNo = '',
    this.fatherName = '',
    this.gender = 'male',
    this.classLabel = 'No class',
  });

  final int id;
  final String name;
  final String admissionNo;
  final String registrationNo;
  final String fatherName;
  final String gender;
  final String classLabel;

  @override
  List<Object?> get props =>
      [id, name, admissionNo, registrationNo, fatherName, gender, classLabel];
}

/// Money taken against one voucher, with its own receipt number.
class FeePayment extends Equatable {
  const FeePayment({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.amount,
    this.note = '',
  });

  final int id;
  final String receiptNo;
  final DateTime date;
  final int amount;
  final String note;

  @override
  List<Object?> get props => [id, receiptNo, date, amount, note];
}

/// One fee bill for one student and one month.
class FeeVoucher extends Equatable {
  const FeeVoucher({
    required this.id,
    required this.date,
    required this.student,
    required this.forMonth,
    this.monthlyFee = 0,
    this.annualFee = 0,
    this.admissionFee = 0,
    this.miscFee = 0,
    this.discount = 0,
    this.previousDues = 0,
    required this.total,
    this.paidAmount = 0,
    required this.status,
    this.carriedForward = false,
    this.payments = const [],
  });

  final int id;

  /// Day the voucher was made.
  final DateTime date;
  final FeeStudent student;

  /// Example: `2026-05`.
  final String forMonth;
  final int monthlyFee;
  final int annualFee;
  final int admissionFee;
  final int miscFee;
  final int discount;
  final int previousDues;
  final int total;
  final int paidAmount;
  final String status;

  /// True when a newer voucher already includes what is still unpaid here.
  final bool carriedForward;

  /// Every payment taken on this voucher, oldest first.
  final List<FeePayment> payments;

  /// Receipt of the newest payment, or empty if nothing was paid yet.
  String get receiptNo => payments.isEmpty ? '' : payments.last.receiptNo;

  /// All receipt numbers, oldest first, e.g. `3, 9`.
  String get receiptNos => payments.map((p) => p.receiptNo).join(', ');

  /// Day of the newest payment, or null if nothing was paid yet.
  DateTime? get lastPaymentDate => payments.isEmpty ? null : payments.last.date;

  int get balance => total - paidAmount;

  /// The voucher as it stood after a given payment (used to print old receipts).
  FeeVoucher withPaid(int paid) => FeeVoucher(
        id: id,
        date: date,
        student: student,
        forMonth: forMonth,
        monthlyFee: monthlyFee,
        annualFee: annualFee,
        admissionFee: admissionFee,
        miscFee: miscFee,
        discount: discount,
        previousDues: previousDues,
        total: total,
        paidAmount: paid,
        status: FeeStatus.of(total, paid),
        carriedForward: carriedForward,
        payments: payments,
      );

  /// Everything except misc fee and discount, which the office can change.
  int get baseTotal => monthlyFee + annualFee + admissionFee + previousDues;

  @override
  List<Object?> get props => [
        id,
        date,
        student,
        forMonth,
        monthlyFee,
        annualFee,
        admissionFee,
        miscFee,
        discount,
        previousDues,
        total,
        paidAmount,
        status,
        carriedForward,
        payments,
      ];
}

/// How much to take for one voucher, and any change to its misc fee or discount.
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.voucherId,
    required this.amount,
    this.miscFee = 0,
    this.discount = 0,
    this.note = '',
  });

  final int voucherId;
  final int amount;
  final int miscFee;
  final int discount;
  final String note;

  @override
  List<Object?> get props => [voucherId, amount, miscFee, discount, note];
}

class ReceiptLine extends Equatable {
  const ReceiptLine({required this.voucher, this.receivedNow});

  final FeeVoucher voucher;

  /// Amount taken in this payment (the money on this receipt).
  final int? receivedNow;

  @override
  List<Object?> get props => [voucher, receivedNow];
}

/// One printed receipt. Brothers and sisters share one receipt number.
class FeeReceipt extends Equatable {
  const FeeReceipt({
    required this.receiptNo,
    required this.date,
    required this.schoolName,
    required this.schoolAddress,
    this.schoolPhone = '',
    this.logoPath,
    required this.lines,
    this.note = '',
  });

  final String receiptNo;
  final DateTime date;
  final String schoolName;
  final String schoolAddress;
  final String schoolPhone;

  /// Full path of the school logo, or null.
  final String? logoPath;
  final List<ReceiptLine> lines;

  /// What the office typed when taking the money. Empty if nothing.
  final String note;

  int get totalPaid => lines.fold(0, (sum, l) => sum + l.voucher.paidAmount);
  int get totalBalance => lines.fold(0, (sum, l) => sum + l.voucher.balance);

  @override
  List<Object?> get props =>
      [receiptNo, date, schoolName, schoolAddress, schoolPhone, logoPath, lines, note];
}

class GenerationResult extends Equatable {
  const GenerationResult({required this.created, required this.skipped});

  final int created;

  /// Students who already have a voucher for this month or a later one.
  final int skipped;

  @override
  List<Object?> get props => [created, skipped];
}

/// A student who still owes fee. [voucher] is the newest one, which already
/// includes older unpaid amounts.
class Defaulter extends Equatable {
  const Defaulter({required this.voucher, required this.monthsPending});

  final FeeVoucher voucher;

  /// Number of vouchers with an unpaid balance.
  final int monthsPending;

  FeeStudent get student => voucher.student;
  int get balance => voucher.balance;

  @override
  List<Object?> get props => [voucher, monthsPending];
}
