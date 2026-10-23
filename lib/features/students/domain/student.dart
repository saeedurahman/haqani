import 'package:equatable/equatable.dart';

class Student extends Equatable {
  const Student({
    this.id = 0,
    required this.admissionNo,
    required this.name,
    this.registrationNo = '',
    this.fatherName = '',
    this.fatherCnic = '',
    this.dob,
    this.gender = 'male',
    this.phone = '',
    this.whatsappNo = '',
    this.address = '',
    this.fatherProfession = '',
    this.fatherEducation = '',
    this.previousSchool = '',
    this.previousClass = '',
    this.classId,
    this.sectionId,
    this.admissionDate,
    this.status = 'active',
    this.leavingDate,
    this.notes = '',
    this.className,
    this.sectionName,
  });

  /// 0 means the student is not saved yet.
  final int id;
  final String admissionNo;
  final String registrationNo;
  final String name;
  final String fatherName;
  final String fatherCnic;
  final DateTime? dob;
  final String gender;
  final String phone;
  final String whatsappNo;
  final String address;
  final String fatherProfession;
  final String fatherEducation;
  final String previousSchool;
  final String previousClass;
  final int? classId;
  final int? sectionId;
  final DateTime? admissionDate;

  /// `active` or `left`.
  final String status;
  final DateTime? leavingDate;
  final String notes;

  /// Read only. Filled when the student is loaded.
  final String? className;
  final String? sectionName;

  bool get isActive => status == 'active';

  /// Example: "Class 1 - A".
  String get classLabel {
    if (className == null) return 'No class';
    return sectionName == null ? className! : '$className - $sectionName';
  }

  @override
  List<Object?> get props => [
        id,
        admissionNo,
        registrationNo,
        name,
        fatherName,
        fatherCnic,
        dob,
        gender,
        phone,
        whatsappNo,
        address,
        fatherProfession,
        fatherEducation,
        previousSchool,
        previousClass,
        classId,
        sectionId,
        admissionDate,
        status,
        leavingDate,
        notes,
        className,
        sectionName,
      ];
}
