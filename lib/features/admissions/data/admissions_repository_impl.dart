import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart' hide Student;
import '../../../core/database/daos/students_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../students/data/student_mapper.dart';
import '../../students/domain/student.dart';
import '../../students/domain/students_repository.dart';
import '../../students/domain/student_extras.dart';
import '../../students/domain/students_exception.dart';
import '../domain/admissions_repository.dart';
import '../domain/leaving_certificate.dart';

class AdmissionsRepositoryImpl implements AdmissionsRepository {
  AdmissionsRepositoryImpl(this._db, this._students) : _dao = _db.studentsDao;

  final AppDatabase _db;
  final StudentsRepository _students;
  final StudentsDao _dao;

  @override
  Future<List<Student>> getAdmissions({
    String query = '',
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _dao.admissions(
      query: query,
      from: from == null ? null : AppDateUtils.toIso(from),
      to: to == null ? null : AppDateUtils.toIso(to),
    );
    return [for (final r in rows) studentFromRow(r)];
  }

  @override
  Future<List<ClassOption>> getClassOptions() => _students.getClassOptions();

  @override
  Future<String> nextAdmissionNo() => _students.suggestAdmissionNo();

  @override
  Future<Student> admit(Student student) async {
    // Number and insert happen together, so two admissions never share a number.
    final id = await _db.transaction(() async {
      final admissionNo = await _students.suggestAdmissionNo();
      return _students.saveStudent(student.withAdmissionNo(admissionNo));
    });
    return (await _students.getStudent(id))!;
  }

  @override
  Future<LeavingCertificate> getCertificateDefaults(int studentId, DateTime today) async {
    final row = await _dao.byId(studentId);
    if (row == null) throw const StudentsException('This student was not found.');
    final s = row.student;

    final vouchers = await _dao.vouchersOf(studentId);
    final due = vouchers.fold<int>(0, (sum, v) => sum + (v.total - v.paidAmount));
    final results = await _dao.resultsOf(studentId);
    final attendance = await _dao.attendanceOf(studentId);

    return LeavingCertificate(
      schoolName: await _setting(AppConstants.settingSchoolName) ?? AppStrings.defaultSchoolName,
      schoolAddress: await _setting(AppConstants.settingSchoolAddress) ?? '',
      schoolPhone: await _setting(AppConstants.settingSchoolPhone) ?? '',
      logoPath: await _setting(AppConstants.settingLogoPath),
      admissionNo: s.admissionNo,
      studentName: s.name,
      fatherName: s.fatherName,
      gender: s.gender,
      dob: AppDateUtils.tryParseIso(s.dob),
      attendedFrom: AppDateUtils.tryParseIso(s.admissionDate),
      attendedTo: AppDateUtils.tryParseIso(s.leavingDate) ?? today,
      duesCleared: due <= 0,
      className: row.className ?? '',
      exam: results.isEmpty ? '' : results.first.exam.name,
      promotedClass: await _nextClassName(s.classId),
      admissionDate: AppDateUtils.tryParseIso(s.admissionDate),
      attendance: _attendanceText(attendance),
      issueDate: today,
    );
  }

  Future<String?> _setting(String key) async {
    final row = await (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    final value = row?.value;
    return (value == null || value.isEmpty) ? null : value;
  }

  /// The class that comes after the student's class in the class order.
  Future<String> _nextClassName(int? classId) async {
    if (classId == null) return '';
    final classes = await _dao.classes();
    final index = classes.indexWhere((c) => c.id == classId);
    if (index < 0 || index + 1 >= classes.length) return '';
    return classes[index + 1].name;
  }

  String _attendanceText(List<AttendanceData> records) {
    if (records.isEmpty) return '';
    final present = records.where((r) => r.status == 'present').length;
    final percent = (present * 100 / records.length).round();
    return '$percent% ($present of ${records.length} days)';
  }
}
