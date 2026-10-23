import 'school_class.dart';

/// Methods throw [ClassesException] when a rule blocks the change.
abstract class ClassesRepository {
  Future<List<SchoolClass>> getClasses();
  Future<List<TeacherOption>> getTeachers();

  Future<void> addClass(String name);
  Future<void> renameClass(int id, String name);

  /// Blocked if the class has sections, students, exams, subjects or fees.
  Future<void> deleteClass(int id);

  /// [orderedIds] is the full list of class ids in the new order.
  Future<void> saveClassOrder(List<int> orderedIds);

  Future<void> addSection(int classId, String name, {int? teacherId});
  Future<void> updateSection(int id, String name, {int? teacherId});

  /// Blocked if students are in the section.
  Future<void> deleteSection(int id);
}
