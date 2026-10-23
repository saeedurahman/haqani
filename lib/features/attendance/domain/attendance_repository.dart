import '../../students/domain/student_extras.dart';
import 'attendance_models.dart';

abstract class AttendanceRepository {
  Future<List<ClassOption>> getClassOptions();

  /// Active students of the class (and section) with what is saved for
  /// [date]. Students with nothing saved have a null status.
  Future<List<AttendanceEntry>> getDailySheet(int classId, int? sectionId, DateTime date);

  /// Saves every entry that has a status. Saving the same day again replaces it.
  Future<void> saveDailySheet(DateTime date, List<AttendanceEntry> entries);

  /// One row per active student, with the status of each marked day.
  Future<List<MonthlyAttendanceRow>> getMonthlyReport(
    int classId,
    int? sectionId,
    int year,
    int month,
  );
}
