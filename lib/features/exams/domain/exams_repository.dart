import '../../students/domain/student_extras.dart';
import 'exam_models.dart';
import 'result_card.dart';

/// Methods throw [ExamsException] when a rule blocks the change.
abstract class ExamsRepository {
  Future<List<ClassOption>> getClassOptions();

  /// Newest first. [classId] null means all classes.
  Future<List<Exam>> getExams({int? classId, String query = ''});

  /// Adds when `exam.id == 0`, otherwise updates.
  Future<void> saveExam(Exam exam);

  /// Blocked if marks were entered for the exam.
  Future<void> deleteExam(int id);

  Future<List<Subject>> getSubjects(int classId);

  /// Adds when `subject.id == 0`, otherwise updates.
  Future<void> saveSubject(Subject subject);

  /// Blocked if any student has marks in the subject.
  Future<void> deleteSubject(int id);

  /// The exam, its class subjects and the students with their marks so far.
  Future<MarksSheet> getMarksSheet(int examId);

  /// Saves marks. A null mark clears it. Nothing is saved if one mark is wrong.
  Future<void> saveMarks(int examId, List<MarkEntry> entries);

  Future<SchoolInfo> getSchoolInfo();

  /// All exams the student has marks in, newest first.
  Future<List<ExamSummary>> getStudentHistory(int studentId);
}
