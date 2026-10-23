import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/fee_exam_tables.dart';
import '../tables/school_tables.dart';
import '../tables/student_tables.dart';

part 'students_dao.g.dart';

class StudentRow {
  const StudentRow(this.student, this.className, this.sectionName);

  final Student student;
  final String? className;
  final String? sectionName;
}

class ResultRow {
  const ResultRow(this.exam, this.subject, this.result);

  final Exam exam;
  final Subject subject;
  final Result result;
}

@DriftAccessor(
  tables: [
    Students,
    SchoolClasses,
    Sections,
    StudentDocuments,
    Attendance,
    FeeVouchers,
    Exams,
    Subjects,
    Results,
  ],
)
class StudentsDao extends DatabaseAccessor<AppDatabase> with _$StudentsDaoMixin {
  StudentsDao(super.db);

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    return select(students).join([
      leftOuterJoin(schoolClasses, schoolClasses.id.equalsExp(students.classId)),
      leftOuterJoin(sections, sections.id.equalsExp(students.sectionId)),
    ]);
  }

  StudentRow _toRow(TypedResult r) => StudentRow(
        r.readTable(students),
        r.readTableOrNull(schoolClasses)?.name,
        r.readTableOrNull(sections)?.name,
      );

  /// Matches name, father name, admission no or registration no.
  Future<List<StudentRow>> search({
    String query = '',
    int? classId,
    bool includeLeft = false,
  }) async {
    final q = query.trim();
    final statement = _joined()
      ..orderBy([OrderingTerm.asc(students.name), OrderingTerm.asc(students.id)]);

    Expression<bool> where = const Constant(true);
    if (!includeLeft) where = where & students.status.equals('active');
    if (classId != null) where = where & students.classId.equals(classId);
    if (q.isNotEmpty) {
      final pattern = '%$q%';
      where = where &
          (students.name.like(pattern) |
              students.fatherName.like(pattern) |
              students.admissionNo.like(pattern) |
              students.registrationNo.like(pattern));
    }
    statement.where(where);
    return [for (final r in await statement.get()) _toRow(r)];
  }

  /// Admission register: newest admission first, active and left students.
  /// [from] and [to] are inclusive `yyyy-MM-dd` dates.
  Future<List<StudentRow>> admissions({
    String query = '',
    String? from,
    String? to,
  }) async {
    final q = query.trim();
    final statement = _joined()
      ..orderBy([
        OrderingTerm.desc(students.admissionDate),
        OrderingTerm.desc(students.id),
      ]);

    Expression<bool> where = const Constant(true);
    if (from != null) where = where & students.admissionDate.isBiggerOrEqualValue(from);
    if (to != null) where = where & students.admissionDate.isSmallerOrEqualValue(to);
    if (q.isNotEmpty) {
      final pattern = '%$q%';
      where = where &
          (students.name.like(pattern) |
              students.fatherName.like(pattern) |
              students.admissionNo.like(pattern));
    }
    statement.where(where);
    return [for (final r in await statement.get()) _toRow(r)];
  }

  Future<StudentRow?> byId(int id) async {
    final statement = _joined()..where(students.id.equals(id));
    final rows = await statement.get();
    return rows.isEmpty ? null : _toRow(rows.first);
  }

  Future<bool> admissionNoExists(String admissionNo, {int? exceptId}) async {
    final rows = await (select(students)
          ..where((t) => t.admissionNo.equals(admissionNo)))
        .get();
    return rows.any((r) => r.id != exceptId);
  }

  Future<List<String>> allAdmissionNos() async {
    final query = selectOnly(students)..addColumns([students.admissionNo]);
    return [for (final r in await query.get()) r.read(students.admissionNo)!];
  }

  Future<int> insertStudent(StudentsCompanion data) => into(students).insert(data);

  Future<void> updateStudent(int id, StudentsCompanion data) {
    return (update(students)..where((t) => t.id.equals(id))).write(data);
  }

  Future<List<SchoolClassesData>> classes() {
    return (select(schoolClasses)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<List<Section>> allSections() {
    return (select(sections)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<List<StudentDocument>> documents(int studentId) {
    return (select(studentDocuments)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<StudentDocument?> documentById(int id) {
    return (select(studentDocuments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertDocument(int studentId, String title, String filePath) {
    return into(studentDocuments).insert(
      StudentDocumentsCompanion.insert(
        studentId: studentId,
        title: title,
        filePath: filePath,
      ),
    );
  }

  Future<void> deleteDocument(int id) {
    return (delete(studentDocuments)..where((t) => t.id.equals(id))).go();
  }

  Future<List<AttendanceData>> attendanceOf(int studentId) {
    return (select(attendance)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<FeeVoucher>> vouchersOf(int studentId) {
    return (select(feeVouchers)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.id)]))
        .get();
  }

  Future<List<ResultRow>> resultsOf(int studentId) async {
    final query = select(results).join([
      innerJoin(exams, exams.id.equalsExp(results.examId)),
      innerJoin(subjects, subjects.id.equalsExp(results.subjectId)),
    ])
      ..where(results.studentId.equals(studentId))
      ..orderBy([OrderingTerm.desc(exams.date), OrderingTerm.asc(subjects.name)]);
    return [
      for (final r in await query.get())
        ResultRow(r.readTable(exams), r.readTable(subjects), r.readTable(results)),
    ];
  }
}
