import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/school_tables.dart';
import '../tables/student_tables.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [Students, Attendance, SchoolClasses, Sections])
class AttendanceDao extends DatabaseAccessor<AppDatabase> with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Future<List<SchoolClassesData>> classes() {
    return (select(schoolClasses)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<List<Section>> allSections() {
    return (select(sections)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Active students of a class (and section when given), sorted by name.
  Future<List<Student>> activeStudents(int classId, int? sectionId) {
    return (select(students)
          ..where((t) {
            Expression<bool> w = t.status.equals('active') & t.classId.equals(classId);
            if (sectionId != null) w = w & t.sectionId.equals(sectionId);
            return w;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.name), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Saved attendance for the given students on one day, by student id.
  Future<Map<int, AttendanceData>> onDate(List<int> studentIds, String date) async {
    if (studentIds.isEmpty) return {};
    final rows = await (select(attendance)
          ..where((t) => t.date.equals(date) & t.studentId.isIn(studentIds)))
        .get();
    return {for (final r in rows) r.studentId: r};
  }

  /// Saved attendance for the given students in one month (`yyyy-MM`).
  Future<List<AttendanceData>> inMonth(List<int> studentIds, String month) {
    if (studentIds.isEmpty) return Future.value(const []);
    return (select(attendance)
          ..where((t) => t.date.like('$month-%') & t.studentId.isIn(studentIds))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Adds or replaces the record for (student, date).
  Future<void> upsert(int studentId, String date, String status, String note) {
    final row = AttendanceCompanion.insert(
      studentId: studentId,
      date: date,
      status: status,
      note: Value(note),
    );
    return into(attendance).insert(
      row,
      onConflict: DoUpdate(
        (old) => AttendanceCompanion(status: Value(status), note: Value(note)),
        target: [attendance.studentId, attendance.date],
      ),
    );
  }
}
