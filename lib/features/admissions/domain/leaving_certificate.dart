import 'package:equatable/equatable.dart';

/// Everything printed on the School Leaving Certificate.
/// The office can change every value before printing.
class LeavingCertificate extends Equatable {
  const LeavingCertificate({
    required this.schoolName,
    required this.schoolAddress,
    required this.admissionNo,
    required this.studentName,
    required this.fatherName,
    required this.gender,
    this.dob,
    this.attendedFrom,
    this.attendedTo,
    this.duesCleared = true,
    this.className = '',
    this.exam = '',
    this.promotedClass = '',
    this.admissionDate,
    this.attendance = '',
    this.discipline = 'Good',
    this.issueDate,
  });

  final String schoolName;
  final String schoolAddress;
  final String admissionNo;
  final String studentName;
  final String fatherName;

  /// `male` or `female`. Decides "S/O" or "D/O".
  final String gender;
  final DateTime? dob;
  final DateTime? attendedFrom;
  final DateTime? attendedTo;
  final bool duesCleared;
  final String className;
  final String exam;
  final String promotedClass;
  final DateTime? admissionDate;
  final String attendance;
  final String discipline;
  final DateTime? issueDate;

  LeavingCertificate copyWith({
    String? admissionNo,
    String? studentName,
    String? fatherName,
    DateTime? Function()? dob,
    DateTime? Function()? attendedFrom,
    DateTime? Function()? attendedTo,
    bool? duesCleared,
    String? className,
    String? exam,
    String? promotedClass,
    DateTime? Function()? admissionDate,
    String? attendance,
    String? discipline,
    DateTime? Function()? issueDate,
  }) {
    return LeavingCertificate(
      schoolName: schoolName,
      schoolAddress: schoolAddress,
      gender: gender,
      admissionNo: admissionNo ?? this.admissionNo,
      studentName: studentName ?? this.studentName,
      fatherName: fatherName ?? this.fatherName,
      dob: dob == null ? this.dob : dob(),
      attendedFrom: attendedFrom == null ? this.attendedFrom : attendedFrom(),
      attendedTo: attendedTo == null ? this.attendedTo : attendedTo(),
      duesCleared: duesCleared ?? this.duesCleared,
      className: className ?? this.className,
      exam: exam ?? this.exam,
      promotedClass: promotedClass ?? this.promotedClass,
      admissionDate: admissionDate == null ? this.admissionDate : admissionDate(),
      attendance: attendance ?? this.attendance,
      discipline: discipline ?? this.discipline,
      issueDate: issueDate == null ? this.issueDate : issueDate(),
    );
  }

  @override
  List<Object?> get props => [
        schoolName,
        schoolAddress,
        admissionNo,
        studentName,
        fatherName,
        gender,
        dob,
        attendedFrom,
        attendedTo,
        duesCleared,
        className,
        exam,
        promotedClass,
        admissionDate,
        attendance,
        discipline,
        issueDate,
      ];
}
