import '../../admissions/domain/admissions_repository.dart';
import '../../attendance/domain/attendance_repository.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exams_repository.dart';
import '../../fees/domain/fees_repository.dart';
import '../../students/domain/student.dart';
import '../../students/domain/student_extras.dart';
import '../../students/domain/students_repository.dart';
import '../domain/report_models.dart';
import '../domain/reports_repository.dart';
import 'class_reports.dart';
import 'fee_reports.dart';
import 'people_reports.dart';

/// Builds every report from the data the other modules already keep.
/// The work is split into three small classes by topic.
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({
    required StudentsRepository students,
    required AdmissionsRepository admissions,
    required AttendanceRepository attendance,
    required FeesRepository fees,
    required ExamsRepository exams,
  }) : _students = students,
       _exams = exams,
       _people = PeopleReports(
         students: students,
         admissions: admissions,
         fees: fees,
         exams: exams,
       ),
       _classes = ClassReports(students, attendance, exams),
       _fees = FeeReports(students, fees);

  final StudentsRepository _students;
  final ExamsRepository _exams;
  final PeopleReports _people;
  final ClassReports _classes;
  final FeeReports _fees;

  @override
  Future<List<ClassOption>> getClassOptions() => _students.getClassOptions();

  @override
  Future<List<Exam>> getExamOptions() => _exams.getExams();

  @override
  Future<List<Student>> findStudents(String query) async {
    if (query.trim().isEmpty) return const [];
    final found = await _students.searchStudents(query: query);
    return found.take(30).toList();
  }

  @override
  Future<SchoolInfo> getSchoolInfo() => _exams.getSchoolInfo();

  @override
  Future<ReportDocument> studentsReport() => _people.studentsReport();

  @override
  Future<ReportDocument> admissionsReport({DateTime? from, DateTime? to}) =>
      _people.admissionsReport(from: from, to: to);

  @override
  Future<ReportDocument> studentHistoryReport(int studentId) =>
      _people.studentHistoryReport(studentId);

  @override
  Future<ReportDocument> attendanceReport({
    required int classId,
    int? sectionId,
    required int year,
    required int month,
  }) => _classes.attendanceReport(
    classId: classId,
    sectionId: sectionId,
    year: year,
    month: month,
  );

  @override
  Future<ReportDocument> examResultsReport(int examId) =>
      _classes.examResultsReport(examId);

  @override
  Future<ReportDocument> feesReport({
    required String month,
    int? classId,
    String? status,
  }) => _fees.feesReport(month: month, classId: classId, status: status);

  @override
  Future<ReportDocument> defaultersReport({int? classId}) =>
      _fees.defaultersReport(classId: classId);
}
