import '../../students/domain/student.dart';
import '../../students/domain/student_extras.dart';
import 'leaving_certificate.dart';

/// Methods throw `StudentsException` when a rule blocks the change.
abstract class AdmissionsRepository {
  /// Admission register, newest first. [from] and [to] are inclusive.
  Future<List<Student>> getAdmissions({
    String query = '',
    DateTime? from,
    DateTime? to,
  });

  Future<List<ClassOption>> getClassOptions();

  /// The number the next admission will get.
  Future<String> nextAdmissionNo();

  /// Saves a new student with the next admission number
  /// (the number inside [student] is ignored). Returns the saved student.
  Future<Student> admit(Student student);

  /// Starting values for the leaving certificate, filled from school records.
  Future<LeavingCertificate> getCertificateDefaults(int studentId, DateTime today);
}
