import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart' hide Exam, Subject;
import '../../../core/database/app_database.dart' as d show Exam, Subject;
import '../../../core/database/daos/exams_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../students/domain/student_extras.dart';
import '../domain/exam_models.dart';
import '../domain/exams_repository.dart';
import '../domain/result_calculator.dart';
import '../domain/result_card.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  ExamsRepositoryImpl(this._db) : _dao = _db.examsDao;

  final AppDatabase _db;
  final ExamsDao _dao;

  @override
  Future<List<ClassOption>> getClassOptions() async {
    final classes = await _dao.classes();
    final sections = await _db.studentsDao.allSections();
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
  Future<List<Exam>> getExams({int? classId, String query = ''}) async {
    final rows = await _dao.findExams(classId: classId, query: query);
    final counts = await _dao.studentsWithMarks();
    return [for (final r in rows) _toExam(r.exam, r.className, counts[r.exam.id] ?? 0)];
  }

  @override
  Future<void> saveExam(Exam exam) async {
    final name = exam.name.trim();
    if (name.isEmpty) throw const ExamsException('Exam name is required.');
    if (exam.classId == 0) throw const ExamsException('Choose a class.');
    final exceptId = exam.id == 0 ? null : exam.id;
    if (await _dao.examNameExists(exam.classId, name, exceptId: exceptId)) {
      throw ExamsException('This class already has an exam named "$name".');
    }
    final date = exam.date == null ? null : AppDateUtils.toIso(exam.date!);

    if (exam.id == 0) {
      await _dao.insertExam(name, exam.classId, date);
      return;
    }
    final current = await _dao.examById(exam.id);
    if (current == null) throw const ExamsException('This exam was not found.');
    if (current.exam.classId != exam.classId && await _dao.resultsInExam(exam.id) > 0) {
      throw const ExamsException('Marks are already entered, so the class cannot be changed.');
    }
    await _dao.updateExam(exam.id, name, exam.classId, date);
  }

  @override
  Future<void> deleteExam(int id) async {
    if (await _dao.resultsInExam(id) > 0) {
      throw const ExamsException('This exam has marks, so it cannot be deleted.');
    }
    await _dao.deleteExam(id);
  }

  @override
  Future<List<Subject>> getSubjects(int classId) async {
    return [for (final s in await _dao.subjectsOf(classId)) _toSubject(s)];
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    final name = subject.name.trim();
    if (name.isEmpty) throw const ExamsException('Subject name is required.');
    if (subject.totalMarks <= 0 || subject.totalMarks > 1000) {
      throw const ExamsException('Total marks must be between 1 and 1000.');
    }
    final exceptId = subject.id == 0 ? null : subject.id;
    if (await _dao.subjectNameExists(subject.classId, name, exceptId: exceptId)) {
      throw ExamsException('This class already has a subject named "$name".');
    }
    if (subject.id == 0) {
      await _dao.insertSubject(subject.classId, name, subject.totalMarks);
      return;
    }
    if (await _dao.subjectById(subject.id) == null) {
      throw const ExamsException('This subject was not found.');
    }
    if (await _dao.maxObtainedOfSubject(subject.id) > subject.totalMarks) {
      throw const ExamsException('A student already has more marks than this total.');
    }
    await _dao.updateSubject(subject.id, name, subject.totalMarks);
  }

  @override
  Future<void> deleteSubject(int id) async {
    if (await _dao.resultsOfSubject(id) > 0) {
      throw const ExamsException('Students have marks in this subject, so it cannot be deleted.');
    }
    await _dao.deleteSubject(id);
  }

  @override
  Future<MarksSheet> getMarksSheet(int examId) async {
    final row = await _dao.examById(examId);
    if (row == null) throw const ExamsException('This exam was not found.');
    final counts = await _dao.studentsWithMarks();
    final exam = _toExam(row.exam, row.className, counts[examId] ?? 0);

    final subjects = [for (final s in await _dao.subjectsOf(exam.classId)) _toSubject(s)];
    final marks = <int, Map<int, int>>{};
    for (final r in await _dao.resultsOfExam(examId)) {
      (marks[r.studentId] ??= {})[r.subjectId] = r.obtainedMarks;
    }
    final students = await _dao.studentsOfExam(examId, exam.classId);
    return MarksSheet(
      exam: exam,
      subjects: subjects,
      students: [
        for (final s in students)
          StudentMarks(
            studentId: s.student.id,
            name: s.student.name,
            admissionNo: s.student.admissionNo,
            fatherName: s.student.fatherName,
            gender: s.student.gender,
            sectionName: s.sectionName,
            marks: marks[s.student.id] ?? const {},
          ),
      ],
    );
  }

  @override
  Future<void> saveMarks(int examId, List<MarkEntry> entries) async {
    final row = await _dao.examById(examId);
    if (row == null) throw const ExamsException('This exam was not found.');
    final subjects = {for (final s in await _dao.subjectsOf(row.exam.classId)) s.id: s};

    for (final e in entries) {
      final subject = subjects[e.subjectId];
      if (subject == null) throw const ExamsException('A subject was not found.');
      final marks = e.marks;
      if (marks != null && (marks < 0 || marks > subject.totalMarks)) {
        throw ExamsException('Marks of ${subject.name} must be from 0 to ${subject.totalMarks}.');
      }
    }
    await _db.transaction(() async {
      for (final e in entries) {
        await _dao.saveMark(examId, e.studentId, e.subjectId, e.marks);
      }
    });
  }

  @override
  Future<SchoolInfo> getSchoolInfo() async {
    Future<String?> setting(String key) async {
      final row = await (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
          .getSingleOrNull();
      final value = row?.value;
      return (value == null || value.isEmpty) ? null : value;
    }

    return SchoolInfo(
      name: await setting(AppConstants.settingSchoolName) ?? AppStrings.defaultSchoolName,
      address: await setting(AppConstants.settingSchoolAddress) ?? '',
      phone: await setting(AppConstants.settingSchoolPhone) ?? '',
      logoPath: await setting(AppConstants.settingLogoPath),
    );
  }

  @override
  Future<List<ExamSummary>> getStudentHistory(int studentId) async {
    final summaries = <ExamSummary>[];
    for (final examId in await _dao.examIdsOfStudent(studentId)) {
      final sheet = await getMarksSheet(examId);
      final results = ResultCalculator.compute(sheet.subjects, sheet.students);
      final mine = results.where((r) => r.student.studentId == studentId).firstOrNull;
      if (mine == null) continue;
      summaries.add(ExamSummary(
        examName: sheet.exam.name,
        examDate: sheet.exam.date,
        className: sheet.exam.className,
        obtained: mine.obtained,
        maxMarks: mine.maxMarks,
        percent: mine.percent,
        grade: mine.grade,
        status: mine.status,
        position: mine.position,
      ));
    }
    summaries.sort((a, b) {
      final byDate = (b.examDate ?? DateTime(0)).compareTo(a.examDate ?? DateTime(0));
      return byDate != 0 ? byDate : b.examName.compareTo(a.examName);
    });
    return summaries;
  }

  Exam _toExam(d.Exam e, String className, int withMarks) => Exam(
        id: e.id,
        name: e.name,
        classId: e.classId,
        className: className,
        date: AppDateUtils.tryParseIso(e.date),
        studentsWithMarks: withMarks,
      );

  Subject _toSubject(d.Subject s) =>
      Subject(id: s.id, classId: s.classId, name: s.name, totalMarks: s.totalMarks);
}
