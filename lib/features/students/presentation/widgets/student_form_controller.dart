import 'package:flutter/material.dart';

import '../../domain/student.dart';

/// Holds what the user types in the student form. No business logic.
class StudentFormController {
  StudentFormController({Student? student, String suggestedAdmissionNo = ''})
      : _original = student,
        admissionNo = TextEditingController(text: student?.admissionNo ?? suggestedAdmissionNo),
        registrationNo = TextEditingController(text: student?.registrationNo),
        name = TextEditingController(text: student?.name),
        fatherName = TextEditingController(text: student?.fatherName),
        fatherCnic = TextEditingController(text: student?.fatherCnic),
        phone = TextEditingController(text: student?.phone),
        whatsappNo = TextEditingController(text: student?.whatsappNo),
        address = TextEditingController(text: student?.address),
        fatherProfession = TextEditingController(text: student?.fatherProfession),
        fatherEducation = TextEditingController(text: student?.fatherEducation),
        previousSchool = TextEditingController(text: student?.previousSchool),
        previousClass = TextEditingController(text: student?.previousClass),
        notes = TextEditingController(text: student?.notes),
        dob = student?.dob,
        gender = student?.gender ?? 'male',
        classId = student?.classId,
        sectionId = student?.sectionId,
        admissionDate = student?.admissionDate ?? (student == null ? DateTime.now() : null);

  final Student? _original;

  final TextEditingController admissionNo;
  final TextEditingController registrationNo;
  final TextEditingController name;
  final TextEditingController fatherName;
  final TextEditingController fatherCnic;
  final TextEditingController phone;
  final TextEditingController whatsappNo;
  final TextEditingController address;
  final TextEditingController fatherProfession;
  final TextEditingController fatherEducation;
  final TextEditingController previousSchool;
  final TextEditingController previousClass;
  final TextEditingController notes;

  DateTime? dob;
  String gender;
  int? classId;
  int? sectionId;
  DateTime? admissionDate;

  Student toStudent() {
    return Student(
      id: _original?.id ?? 0,
      admissionNo: admissionNo.text,
      registrationNo: registrationNo.text,
      name: name.text,
      fatherName: fatherName.text,
      fatherCnic: fatherCnic.text,
      dob: dob,
      gender: gender,
      phone: phone.text,
      whatsappNo: whatsappNo.text,
      address: address.text,
      fatherProfession: fatherProfession.text,
      fatherEducation: fatherEducation.text,
      previousSchool: previousSchool.text,
      previousClass: previousClass.text,
      classId: classId,
      sectionId: classId == null ? null : sectionId,
      admissionDate: admissionDate,
      notes: notes.text,
    );
  }

  void dispose() {
    for (final c in [
      admissionNo,
      registrationNo,
      name,
      fatherName,
      fatherCnic,
      phone,
      whatsappNo,
      address,
      fatherProfession,
      fatherEducation,
      previousSchool,
      previousClass,
      notes,
    ]) {
      c.dispose();
    }
  }
}
