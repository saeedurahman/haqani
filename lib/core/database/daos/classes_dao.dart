import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/fee_exam_tables.dart';
import '../tables/school_tables.dart';
import '../tables/student_tables.dart';

part 'classes_dao.g.dart';

class SectionWithTeacher {
  const SectionWithTeacher(this.section, this.teacherName);

  final Section section;
  final String? teacherName;
}

@DriftAccessor(
  tables: [
    SchoolClasses,
    Sections,
    Staff,
    Students,
    Exams,
    Subjects,
    FeeStructure,
  ],
)
class ClassesDao extends DatabaseAccessor<AppDatabase> with _$ClassesDaoMixin {
  ClassesDao(super.db);

  Future<List<SchoolClassesData>> allClasses() {
    return (select(schoolClasses)..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .get();
  }

  Future<List<SectionWithTeacher>> allSections() async {
    final query = select(sections).join([
      leftOuterJoin(staff, staff.id.equalsExp(sections.classTeacherId)),
    ])..orderBy([OrderingTerm.asc(sections.name)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        SectionWithTeacher(
          row.readTable(sections),
          row.readTableOrNull(staff)?.name,
        ),
    ];
  }

  Future<List<StaffData>> activeStaff() {
    return (select(staff)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Active students per class id.
  Future<Map<int, int>> activeStudentCountByClass() async {
    final count = students.id.count();
    final query = selectOnly(students)
      ..addColumns([students.classId, count])
      ..where(students.status.equals('active') & students.classId.isNotNull())
      ..groupBy([students.classId]);
    final rows = await query.get();
    return {
      for (final r in rows) r.read(students.classId)!: r.read(count) ?? 0,
    };
  }

  /// Active students per section id.
  Future<Map<int, int>> activeStudentCountBySection() async {
    final count = students.id.count();
    final query = selectOnly(students)
      ..addColumns([students.sectionId, count])
      ..where(students.status.equals('active') & students.sectionId.isNotNull())
      ..groupBy([students.sectionId]);
    final rows = await query.get();
    return {
      for (final r in rows) r.read(students.sectionId)!: r.read(count) ?? 0,
    };
  }

  Future<int> _count(
    TableInfo<Table, dynamic> table,
    Expression<int> id,
    Expression<bool> where,
  ) async {
    final count = id.count();
    final query = selectOnly(table)
      ..addColumns([count])
      ..where(where);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// All students (active or left) in the class.
  Future<int> studentsInClass(int classId) =>
      _count(students, students.id, students.classId.equals(classId));

  Future<int> studentsInSection(int sectionId) =>
      _count(students, students.id, students.sectionId.equals(sectionId));

  Future<int> sectionsInClass(int classId) =>
      _count(sections, sections.id, sections.classId.equals(classId));

  /// Exams, subjects or fee structure already tied to the class.
  Future<int> otherUsesOfClass(int classId) async {
    final exam = await _count(exams, exams.id, exams.classId.equals(classId));
    final subject = await _count(
      subjects,
      subjects.id,
      subjects.classId.equals(classId),
    );
    final fee = await _count(
      feeStructure,
      feeStructure.id,
      feeStructure.classId.equals(classId),
    );
    return exam + subject + fee;
  }

  Future<bool> classNameExists(String name, {int? exceptId}) async {
    final rows = await (select(
      schoolClasses,
    )..where((t) => t.name.lower().equals(name.toLowerCase()))).get();
    return rows.any((r) => r.id != exceptId);
  }

  Future<bool> sectionNameExists(
    int classId,
    String name, {
    int? exceptId,
  }) async {
    final rows =
        await (select(sections)..where(
              (t) =>
                  t.classId.equals(classId) &
                  t.name.lower().equals(name.toLowerCase()),
            ))
            .get();
    return rows.any((r) => r.id != exceptId);
  }

  Future<int> nextSortOrder() async {
    final maxOrder = schoolClasses.sortOrder.max();
    final query = selectOnly(schoolClasses)..addColumns([maxOrder]);
    return ((await query.getSingle()).read(maxOrder) ?? -1) + 1;
  }

  Future<void> insertClass(String name, int sortOrder) {
    return into(schoolClasses).insert(
      SchoolClassesCompanion.insert(name: name, sortOrder: Value(sortOrder)),
    );
  }

  Future<void> renameClass(int id, String name) {
    return (update(schoolClasses)..where((t) => t.id.equals(id))).write(
      SchoolClassesCompanion(name: Value(name)),
    );
  }

  Future<void> deleteClass(int id) {
    return (delete(schoolClasses)..where((t) => t.id.equals(id))).go();
  }

  /// Saves the order: the first id gets 0, the next 1, and so on.
  Future<void> saveClassOrder(List<int> orderedIds) {
    return transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(schoolClasses)..where((t) => t.id.equals(orderedIds[i])))
            .write(SchoolClassesCompanion(sortOrder: Value(i)));
      }
    });
  }

  Future<void> insertSection(int classId, String name, int? teacherId) {
    return into(sections).insert(
      SectionsCompanion.insert(
        classId: classId,
        name: name,
        classTeacherId: Value(teacherId),
      ),
    );
  }

  Future<void> updateSection(int id, String name, int? teacherId) {
    return (update(sections)..where((t) => t.id.equals(id))).write(
      SectionsCompanion(name: Value(name), classTeacherId: Value(teacherId)),
    );
  }

  Future<void> deleteSection(int id) {
    return (delete(sections)..where((t) => t.id.equals(id))).go();
  }
}
