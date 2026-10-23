import '../../../core/database/daos/students_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/student.dart';

Student studentFromRow(StudentRow row) {
  final s = row.student;
  return Student(
    id: s.id,
    admissionNo: s.admissionNo,
    registrationNo: s.registrationNo,
    name: s.name,
    fatherName: s.fatherName,
    fatherCnic: s.fatherCnic,
    dob: AppDateUtils.tryParseIso(s.dob),
    gender: s.gender,
    phone: s.phone,
    whatsappNo: s.whatsappNo,
    address: s.address,
    fatherProfession: s.fatherProfession,
    fatherEducation: s.fatherEducation,
    previousSchool: s.previousSchool,
    previousClass: s.previousClass,
    classId: s.classId,
    sectionId: s.sectionId,
    admissionDate: AppDateUtils.tryParseIso(s.admissionDate),
    status: s.status,
    leavingDate: AppDateUtils.tryParseIso(s.leavingDate),
    notes: s.notes,
    className: row.className,
    sectionName: row.sectionName,
  );
}
