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

/// One fee bill for one student and one month.
class FeeVoucher extends Equatable {
  const FeeVoucher({
    required this.id,
    required this.receiptNo,
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
  });

  final int id;

  /// Empty until the first payment.
  final String receiptNo;

  /// Day the voucher was made, or the day of the last payment.
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

  int get balance => total - paidAmount;

  /// Everything except misc fee and discount, which the office can change.
  int get baseTotal => monthlyFee + annualFee + admissionFee + previousDues;

  @override
  List<Object?> get props => [
        id,
        receiptNo,
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
      ];
}

/// How much to take for one voucher, and any change to its misc fee or discount.
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.voucherId,
    required this.amount,
    this.miscFee = 0,
    this.discount = 0,
  });

  final int voucherId;
  final int amount;
  final int miscFee;
  final int discount;

  @override
  List<Object?> get props => [voucherId, amount, miscFee, discount];
}

class ReceiptLine extends Equatable {
  const ReceiptLine({required this.voucher, this.receivedNow});

  final FeeVoucher voucher;

  /// Amount taken in this payment. Null when a receipt is printed again later.
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
    required this.lines,
  });

  final String receiptNo;
  final DateTime date;
  final String schoolName;
  final String schoolAddress;
  final List<ReceiptLine> lines;

  int get totalPaid => lines.fold(0, (sum, l) => sum + l.voucher.paidAmount);
  int get totalBalance => lines.fold(0, (sum, l) => sum + l.voucher.balance);

  @override
  List<Object?> get props => [receiptNo, date, schoolName, schoolAddress, lines];
}

class GenerationResult extends Equatable {
  const GenerationResult({required this.created, required this.skipped});

  final int created;

  /// Students who already have a voucher for this month or a later one.
  final int skipped;

  @override
  List<Object?> get props => [created, skipped];
}
