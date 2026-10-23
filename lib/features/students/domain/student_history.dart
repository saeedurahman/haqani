import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.date,
    required this.status,
    this.note = '',
  });

  final DateTime date;

  /// `present`, `absent` or `leave`.
  final String status;
  final String note;

  @override
  List<Object?> get props => [date, status, note];
}

class FeeRecord extends Equatable {
  const FeeRecord({
    required this.receiptNo,
    required this.date,
    required this.forMonth,
    required this.total,
    required this.paidAmount,
    required this.status,
  });

  final String receiptNo;
  final DateTime date;
  final String forMonth;
  final int total;
  final int paidAmount;

  /// `paid`, `partial` or `unpaid`.
  final String status;

  int get due => total - paidAmount;

  @override
  List<Object?> get props => [receiptNo, date, forMonth, total, paidAmount, status];
}

class ResultRecord extends Equatable {
  const ResultRecord({
    required this.examName,
    required this.subjectName,
    required this.obtainedMarks,
    required this.totalMarks,
  });

  final String examName;
  final String subjectName;
  final int obtainedMarks;
  final int totalMarks;

  @override
  List<Object?> get props => [examName, subjectName, obtainedMarks, totalMarks];
}

class StudentHistory extends Equatable {
  const StudentHistory({
    this.attendance = const [],
    this.fees = const [],
    this.results = const [],
  });

  final List<AttendanceRecord> attendance;
  final List<FeeRecord> fees;
  final List<ResultRecord> results;

  int countAttendance(String status) =>
      attendance.where((a) => a.status == status).length;

  @override
  List<Object?> get props => [attendance, fees, results];
}
