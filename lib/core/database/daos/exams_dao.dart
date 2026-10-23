import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/fee_exam_tables.dart';
import '../tables/school_tables.dart';
import '../tables/student_tables.dart';

part 'exams_dao.g.dart';

class ExamRow {
  const ExamRow(this.exam, this.className);

  final Exam exam;
  final String className;
}

class ExamStudentRow {
  const ExamStudentRow(this.student, this.sectionName);

  final Student student;
  final String? sectionName;
}

@DriftAccessor(tables: [Exams, Subjects, Results, Students, SchoolClasses, Sections])
class ExamsDao extends DatabaseAccessor<AppDatabase> with _$ExamsDaoMixin {
  ExamsDao(super.db);

  Future<List<SchoolClassesData>> classes() {
    return (select(schoolClasses)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  // ---- exams ----

  /// Newest first. Matches the exam name.
  Future<List<ExamRow>> findExams({int? classId, String query = ''}) async {
    final q = query.trim();
    final statement = select(exams).join([
      innerJoin(schoolClasses, schoolClasses.id.equalsExp(exams.classId)),
    ])
      ..orderBy([OrderingTerm.desc(exams.date), OrderingTerm.desc(exams.id)]);
    Expression<bool> where = const Constant(true);
    if (classId != null) where = where & exams.classId.equals(classId);
    if (q.isNotEmpty) where = where & exams.name.like('%$q%');
    statement.where(where);
    return [
      for (final r in await statement.get())
        ExamRow(r.readTable(exams), r.readTable(schoolClasses).name),
    ];
  }

  Future<ExamRow?> examById(int id) async {
    final statement = select(exams).join([
      innerJoin(schoolClasses, schoolClasses.id.equalsExp(exams.classId)),
    ])
      ..where(exams.id.equals(id));
    final rows = await statement.get();
    if (rows.isEmpty) return null;
    return ExamRow(rows.first.readTable(exams), rows.first.readTable(schoolClasses).name);
  }

  Future<bool> examNameExists(int classId, String name, {int? exceptId}) async {
    final rows = await (select(exams)
          ..where((t) => t.classId.equals(classId) & t.name.lower().equals(name.toLowerCase())))
        .get();
    return rows.any((r) => r.id != exceptId);
  }

  Future<int> insertExam(String name, int classId, String? date) {
    return into(exams).insert(ExamsCompanion.insert(name: name, classId: classId, date: Value(date)));
  }

  Future<void> updateExam(int id, String name, int classId, String? date) {
    return (update(exams)..where((t) => t.id.equals(id))).write(
      ExamsCompanion(name: Value(name), classId: Value(classId), date: Value(date)),
    );
  }

  Future<void> deleteExam(int id) => (delete(exams)..where((t) => t.id.equals(id))).go();

  /// Number of students who have at least one mark, per exam id.
  Future<Map<int, int>> studentsWithMarks() async {
    final count = results.studentId.count(distinct: true);
    final query = selectOnly(results)
      ..addColumns([results.examId, count])
      ..groupBy([results.examId]);
    return {for (final r in await query.get()) r.read(results.examId)!: r.read(count) ?? 0};
  }

  Future<int> resultsInExam(int examId) async {
    final count = results.id.count();
    final query = selectOnly(results)
      ..addColumns([count])
      ..where(results.examId.equals(examId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  // ---- subjects ----

  Future<List<Subject>> subjectsOf(int classId) {
    return (select(subjects)
          ..where((t) => t.classId.equals(classId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<Subject?> subjectById(int id) {
    return (select(subjects)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> subjectNameExists(int classId, String name, {int? exceptId}) async {
    final rows = await (select(subjects)
          ..where((t) => t.classId.equals(classId) & t.name.lower().equals(name.toLowerCase())))
        .get();
    return rows.any((r) => r.id != exceptId);
  }

  Future<void> insertSubject(int classId, String name, int totalMarks) {
    return into(subjects).insert(
      SubjectsCompanion.insert(classId: classId, name: name, totalMarks: Value(totalMarks)),
    );
  }

  Future<void> updateSubject(int id, String name, int totalMarks) {
    return (update(subjects)..where((t) => t.id.equals(id)))
        .write(SubjectsCompanion(name: Value(name), totalMarks: Value(totalMarks)));
  }

  Future<void> deleteSubject(int id) => (delete(subjects)..where((t) => t.id.equals(id))).go();

  Future<int> resultsOfSubject(int subjectId) async {
    final count = results.id.count();
    final query = selectOnly(results)
      ..addColumns([count])
      ..where(results.subjectId.equals(subjectId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Biggest mark any student got in the subject, 0 if none.
  Future<int> maxObtainedOfSubject(int subjectId) async {
    final maxMarks = results.obtainedMarks.max();
    final query = selectOnly(results)
      ..addColumns([maxMarks])
      ..where(results.subjectId.equals(subjectId));
    return (await query.getSingle()).read(maxMarks) ?? 0;
  }

  // ---- marks ----

  Future<List<Result>> resultsOfExam(int examId) {
    return (select(results)..where((t) => t.examId.equals(examId))).get();
  }

  /// Active students of the exam's class, plus anyone who already has marks.
  Future<List<ExamStudentRow>> studentsOfExam(int examId, int classId) async {
    final withMarks = selectOnly(results, distinct: true)
      ..addColumns([results.studentId])
      ..where(results.examId.equals(examId));
    final ids = [for (final r in await withMarks.get()) r.read(results.studentId)!];

    final statement = select(students).join([
      leftOuterJoin(sections, sections.id.equalsExp(students.sectionId)),
    ])
      ..where(
        (students.status.equals('active') & students.classId.equals(classId)) |
            students.id.isIn(ids),
      )
      ..orderBy([OrderingTerm.asc(students.name), OrderingTerm.asc(students.id)]);
    return [
      for (final r in await statement.get())
        ExamStudentRow(r.readTable(students), r.readTableOrNull(sections)?.name),
    ];
  }

  Future<void> saveMark(int examId, int studentId, int subjectId, int? marks) async {
    final existing = await (select(results)
          ..where((t) =>
              t.examId.equals(examId) & t.studentId.equals(studentId) & t.subjectId.equals(subjectId)))
        .get();
    if (marks == null) {
      if (existing.isNotEmpty) {
        await (delete(results)..where((t) => t.id.isIn([for (final e in existing) e.id]))).go();
      }
      return;
    }
    if (existing.isEmpty) {
      await into(results).insert(ResultsCompanion.insert(
        examId: examId,
        studentId: studentId,
        subjectId: subjectId,
        obtainedMarks: Value(marks),
      ));
    } else {
      await (update(results)..where((t) => t.id.equals(existing.first.id)))
          .write(ResultsCompanion(obtainedMarks: Value(marks)));
    }
  }

  /// Exam ids where the student has marks.
  Future<List<int>> examIdsOfStudent(int studentId) async {
    final query = selectOnly(results, distinct: true)
      ..addColumns([results.examId])
      ..where(results.studentId.equals(studentId));
    return [for (final r in await query.get()) r.read(results.examId)!];
  }
}
