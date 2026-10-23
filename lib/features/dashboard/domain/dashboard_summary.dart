import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.schoolName,
    required this.totalStudents,
    required this.totalStaff,
    required this.presentToday,
    required this.feesCollectedThisMonth,
    this.absentToday = 0,
    this.defaulters = 0,
    this.pendingFees = 0,
    this.lastBackup,
  });

  final String schoolName;
  final int totalStudents;
  final int totalStaff;
  final int presentToday;
  final int absentToday;

  /// Active students who still owe fee, and how much (whole PKR).
  final int defaulters;
  final int pendingFees;

  /// Whole PKR.
  final int feesCollectedThisMonth;
  final DateTime? lastBackup;

  @override
  List<Object?> get props => [
        schoolName,
        totalStudents,
        totalStaff,
        presentToday,
        feesCollectedThisMonth,
        absentToday,
        defaulters,
        pendingFees,
        lastBackup,
      ];
}
