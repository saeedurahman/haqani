import '../../../core/database/app_database.dart' hide Student;
import '../../../core/database/daos/attendance_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../students/domain/student_extras.dart';
import '../domain/attendance_models.dart';
import '../domain/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._db) : _dao = _db.attendanceDao;

  final AppDatabase _db;
  final AttendanceDao _dao;

  @override
  Future<List<ClassOption>> getClassOptions() async {
    final classes = await _dao.classes();
    final sections = await _dao.allSections();
    return [
      for (final c in classes)
        ClassOption(
          id: c.id,
          name: c.name,
          sections: [
            for (final s in sections.where((s) => s.classId == c.id))
              SectionOption(id: s.id, name: s.name),
          ],
        ),
    ];
  }

  @override
  Future<List<AttendanceEntry>> getDailySheet(
    int classId,
    int? sectionId,
    DateTime date,
  ) async {
    final students = await _dao.activeStudents(classId, sectionId);
    final saved = await _dao.onDate(
      [for (final s in students) s.id],
      AppDateUtils.toIso(date),
    );
    return [
      for (final s in students)
        AttendanceEntry(
          studentId: s.id,
          name: s.name,
          admissionNo: s.admissionNo,
          gender: s.gender,
          status: saved[s.id]?.status,
          note: saved[s.id]?.note ?? '',
        ),
    ];
  }

  @override
  Future<void> saveDailySheet(DateTime date, List<AttendanceEntry> entries) {
    final iso = AppDateUtils.toIso(date);
    return _db.transaction(() async {
      for (final e in entries) {
        final status = e.status;
        if (status == null) continue;
        await _dao.upsert(e.studentId, iso, status, e.note);
      }
    });
  }

  @override
  Future<List<MonthlyAttendanceRow>> getMonthlyReport(
    int classId,
    int? sectionId,
    int year,
    int month,
  ) async {
    final students = await _dao.activeStudents(classId, sectionId);
    final records = await _dao.inMonth(
      [for (final s in students) s.id],
      AppDateUtils.toMonth(DateTime(year, month)),
    );

    final byStudent = <int, Map<int, String>>{};
    for (final r in records) {
      final day = DateTime.parse(r.date).day;
      (byStudent[r.studentId] ??= {})[day] = r.status;
    }
    return [
      for (final s in students)
        MonthlyAttendanceRow(
          studentId: s.id,
          name: s.name,
          admissionNo: s.admissionNo,
          gender: s.gender,
          days: byStudent[s.id] ?? const {},
        ),
    ];
  }
}
