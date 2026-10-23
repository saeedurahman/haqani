import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.schoolName,
    required this.totalStudents,
    required this.totalStaff,
    required this.presentToday,
    required this.feesCollectedThisMonth,
    this.lastBackup,
  });

  final String schoolName;
  final int totalStudents;
  final int totalStaff;
  final int presentToday;

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
        lastBackup,
      ];
}
