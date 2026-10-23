import '../../../core/database/app_database.dart';
import '../../../core/database/daos/classes_dao.dart';
import '../domain/classes_exception.dart';
import '../domain/classes_repository.dart';
import '../domain/school_class.dart';

class ClassesRepositoryImpl implements ClassesRepository {
  ClassesRepositoryImpl(AppDatabase db) : _dao = db.classesDao;

  final ClassesDao _dao;

  @override
  Future<List<SchoolClass>> getClasses() async {
    final classes = await _dao.allClasses();
    final sections = await _dao.allSections();
    final classCounts = await _dao.activeStudentCountByClass();
    final sectionCounts = await _dao.activeStudentCountBySection();

    return [
      for (final c in classes)
        SchoolClass(
          id: c.id,
          name: c.name,
          sortOrder: c.sortOrder,
          studentCount: classCounts[c.id] ?? 0,
          sections: [
            for (final s in sections.where((s) => s.section.classId == c.id))
              SchoolSection(
                id: s.section.id,
                classId: c.id,
                name: s.section.name,
                classTeacherId: s.section.classTeacherId,
                classTeacherName: s.teacherName,
                studentCount: sectionCounts[s.section.id] ?? 0,
              ),
          ],
        ),
    ];
  }

  @override
  Future<List<TeacherOption>> getTeachers() async {
    final staff = await _dao.activeStaff();
    return [for (final s in staff) TeacherOption(id: s.id, name: s.name)];
  }

  @override
  Future<void> addClass(String name) async {
    final clean = await _cleanClassName(name);
    await _dao.insertClass(clean, await _dao.nextSortOrder());
  }

  @override
  Future<void> renameClass(int id, String name) async {
    final clean = await _cleanClassName(name, exceptId: id);
    await _dao.renameClass(id, clean);
  }

  @override
  Future<void> deleteClass(int id) async {
    if (await _dao.sectionsInClass(id) > 0) {
      throw const ClassesException(
        'This class has sections. Delete the sections first.',
      );
    }
    if (await _dao.studentsInClass(id) > 0) {
      throw const ClassesException(
        'This class has students. Move the students to another class first.',
      );
    }
    if (await _dao.otherUsesOfClass(id) > 0) {
      throw const ClassesException(
        'This class is used in fees or exams, so it cannot be deleted.',
      );
    }
    await _dao.deleteClass(id);
  }

  @override
  Future<void> saveClassOrder(List<int> orderedIds) =>
      _dao.saveClassOrder(orderedIds);

  @override
  Future<void> addSection(int classId, String name, {int? teacherId}) async {
    final clean = await _cleanSectionName(classId, name);
    await _dao.insertSection(classId, clean, teacherId);
  }

  @override
  Future<void> updateSection(int id, String name, {int? teacherId}) async {
    final classId = (await _dao.allSections())
        .firstWhere((s) => s.section.id == id)
        .section
        .classId;
    final clean = await _cleanSectionName(classId, name, exceptId: id);
    await _dao.updateSection(id, clean, teacherId);
  }

  @override
  Future<void> deleteSection(int id) async {
    if (await _dao.studentsInSection(id) > 0) {
      throw const ClassesException(
        'This section has students. Move the students to another section first.',
      );
    }
    await _dao.deleteSection(id);
  }

  Future<String> _cleanClassName(String name, {int? exceptId}) async {
    final clean = name.trim();
    if (clean.isEmpty) throw const ClassesException('Class name is required.');
    if (await _dao.classNameExists(clean, exceptId: exceptId)) {
      throw ClassesException('A class named "$clean" already exists.');
    }
    return clean;
  }

  Future<String> _cleanSectionName(
    int classId,
    String name, {
    int? exceptId,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) {
      throw const ClassesException('Section name is required.');
    }
    if (await _dao.sectionNameExists(classId, clean, exceptId: exceptId)) {
      throw ClassesException(
        'This class already has a section named "$clean".',
      );
    }
    return clean;
  }
}
