import 'student.dart';
import 'student_extras.dart';
import 'student_history.dart';

/// Methods throw [StudentsException] when a rule blocks the change.
abstract class StudentsRepository {
  /// Matches name, father name, admission no or registration no.
  Future<List<Student>> searchStudents({
    String query = '',
    int? classId,
    bool includeLeft = false,
  });

  Future<Student?> getStudent(int id);

  /// Inserts when `student.id == 0`, otherwise updates. Returns the saved id.
  Future<int> saveStudent(Student student);

  /// Soft delete: marks the student as left. History is kept.
  Future<void> markAsLeft(int id, DateTime leavingDate);

  Future<void> reactivate(int id);

  /// Next free admission number, based on the biggest number used so far.
  Future<String> suggestAdmissionNo();

  Future<List<ClassOption>> getClassOptions();

  Future<List<StudentDocumentItem>> getDocuments(int studentId);

  /// Copies the file into the app documents folder.
  Future<void> addDocument(int studentId, String title, String sourcePath);
  Future<void> deleteDocument(int documentId);

  Future<StudentHistory> getHistory(int studentId);
}
