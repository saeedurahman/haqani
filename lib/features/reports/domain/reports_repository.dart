import '../../exams/domain/exam_models.dart';
import '../../students/domain/student.dart';
import '../../students/domain/student_extras.dart';
import 'report_models.dart';

/// Every method builds a [ReportDocument]. Methods throw [ReportsException]
/// when the choice is not valid (for example an unknown exam).
abstract class ReportsRepository {
  Future<List<ClassOption>> getClassOptions();

  /// Exams for the exam results report, newest first.
  Future<List<Exam>> getExamOptions();

  /// Active students matching a name, father name or ID.
  Future<List<Student>> findStudents(String query);

  Future<SchoolInfo> getSchoolInfo();

  /// Active students by class, boys and girls, and by section.
  Future<ReportDocument> studentsReport();

  /// Students admitted from [from] to [to], both included.
  Future<ReportDocument> admissionsReport({DateTime? from, DateTime? to});

  Future<ReportDocument> attendanceReport({
    required int classId,
    int? sectionId,
    required int year,
    required int month,
  });

  /// Fee vouchers of a month. [status] is `paid`, `partial`, `unpaid` or null for all.
  Future<ReportDocument> feesReport({required String month, int? classId, String? status});

  /// Students who still owe fee.
  Future<ReportDocument> defaultersReport({int? classId});

  Future<ReportDocument> examResultsReport(int examId);

  /// Profile, attendance by month, fee history and exam results of one student.
  Future<ReportDocument> studentHistoryReport(int studentId);
}
