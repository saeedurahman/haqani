import 'package:equatable/equatable.dart';

class AttendanceStatus {
  const AttendanceStatus._();

  static const present = 'present';
  static const absent = 'absent';
  static const leave = 'leave';

  static const all = [present, absent, leave];

  static String label(String? status) => switch (status) {
        present => 'Present',
        absent => 'Absent',
        leave => 'Leave',
        _ => 'Not marked',
      };
}

/// One student on one day. [status] is null when nothing is saved yet.
class AttendanceEntry extends Equatable {
  const AttendanceEntry({
    required this.studentId,
    required this.name,
    required this.admissionNo,
    this.gender = 'male',
    this.status,
    this.note = '',
  });

  final int studentId;
  final String name;
  final String admissionNo;
  final String gender;
  final String? status;
  final String note;

  AttendanceEntry withStatus(String? value) => AttendanceEntry(
        studentId: studentId,
        name: name,
        admissionNo: admissionNo,
        gender: gender,
        status: value,
        note: note,
      );

  @override
  List<Object?> get props => [studentId, name, admissionNo, gender, status, note];
}

/// One student for a whole month.
class MonthlyAttendanceRow extends Equatable {
  const MonthlyAttendanceRow({
    required this.studentId,
    required this.name,
    required this.admissionNo,
    this.gender = 'male',
    this.days = const {},
  });

  final int studentId;
  final String name;
  final String admissionNo;
  final String gender;

  /// Day of the month (1 to 31) -> status.
  final Map<int, String> days;

  int count(String status) => days.values.where((s) => s == status).length;

  int get present => count(AttendanceStatus.present);
  int get absent => count(AttendanceStatus.absent);
  int get leave => count(AttendanceStatus.leave);
  int get markedDays => days.length;

  /// Present days out of the days that were marked, 0 to 100.
  int get percent => markedDays == 0 ? 0 : (present * 100 / markedDays).round();

  @override
  List<Object?> get props => [studentId, name, admissionNo, gender, days];
}
