import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart' hide Student;
import '../../../core/database/daos/students_dao.dart';
import '../../../core/services/app_paths.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/student.dart';
import 'student_mapper.dart';
import '../domain/student_extras.dart';
import '../domain/student_history.dart';
import '../domain/students_exception.dart';
import '../domain/students_repository.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  /// [documentsRoot] is where attached files are copied. Tests pass a temp folder.
  StudentsRepositoryImpl(AppDatabase db, {Future<Directory> Function()? documentsRoot})
      : _dao = db.studentsDao,
        _documentsRoot = documentsRoot ?? _defaultDocumentsRoot;

  final StudentsDao _dao;
  final Future<Directory> Function() _documentsRoot;

  static Future<Directory> _defaultDocumentsRoot() => AppPaths().documentsDir();

  @override
  Future<List<Student>> searchStudents({
    String query = '',
    int? classId,
    bool includeLeft = false,
  }) async {
    final rows = await _dao.search(query: query, classId: classId, includeLeft: includeLeft);
    return [for (final r in rows) studentFromRow(r)];
  }

  @override
  Future<Student?> getStudent(int id) async {
    final row = await _dao.byId(id);
    return row == null ? null : studentFromRow(row);
  }

  @override
  Future<int> saveStudent(Student student) async {
    final admissionNo = student.admissionNo.trim();
    final name = student.name.trim();
    if (admissionNo.isEmpty) throw const StudentsException('Admission number is required.');
    if (name.isEmpty) throw const StudentsException('Student name is required.');
    final exceptId = student.id == 0 ? null : student.id;
    if (await _dao.admissionNoExists(admissionNo, exceptId: exceptId)) {
      throw StudentsException('Admission number $admissionNo is already used.');
    }

    final isNew = student.id == 0;
    final data = StudentsCompanion(
      admissionNo: Value(admissionNo),
      registrationNo: Value(student.registrationNo.trim()),
      name: Value(name),
      fatherName: Value(student.fatherName.trim()),
      fatherCnic: Value(student.fatherCnic.trim()),
      dob: Value(_iso(student.dob)),
      gender: Value(student.gender),
      phone: Value(student.phone.trim()),
      whatsappNo: Value(student.whatsappNo.trim()),
      address: Value(student.address.trim()),
      fatherProfession: Value(student.fatherProfession.trim()),
      fatherEducation: Value(student.fatherEducation.trim()),
      previousSchool: Value(student.previousSchool.trim()),
      previousClass: Value(student.previousClass.trim()),
      classId: Value(student.classId),
      sectionId: Value(student.sectionId),
      admissionDate: Value(_iso(student.admissionDate)),
      notes: Value(student.notes.trim()),
    );

    if (isNew) return _dao.insertStudent(data);
    await _dao.updateStudent(student.id, data);
    return student.id;
  }

  @override
  Future<void> markAsLeft(int id, DateTime leavingDate) {
    return _dao.updateStudent(
      id,
      StudentsCompanion(
        status: const Value('left'),
        leavingDate: Value(AppDateUtils.toIso(leavingDate)),
      ),
    );
  }

  @override
  Future<void> reactivate(int id) {
    return _dao.updateStudent(
      id,
      const StudentsCompanion(status: Value('active'), leavingDate: Value(null)),
    );
  }

  @override
  Future<String> suggestAdmissionNo() async {
    var biggest = 0;
    for (final no in await _dao.allAdmissionNos()) {
      final n = int.tryParse(no.trim());
      if (n != null && n > biggest) biggest = n;
    }
    return '${biggest + 1}';
  }

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
  Future<List<StudentDocumentItem>> getDocuments(int studentId) async {
    final docs = await _dao.documents(studentId);
    return [
      for (final d in docs)
        StudentDocumentItem(id: d.id, title: d.title, filePath: d.filePath),
    ];
  }

  @override
  Future<void> addDocument(int studentId, String title, String sourcePath) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw const StudentsException('Document title is required.');
    final source = File(sourcePath);
    if (!await source.exists()) throw const StudentsException('The file was not found.');

    final root = await _documentsRoot();
    final folder = Directory(p.join(root.path, '$studentId'));
    await folder.create(recursive: true);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final target = p.join(folder.path, '${stamp}_${p.basename(sourcePath)}');
    await source.copy(target);
    await _dao.insertDocument(studentId, cleanTitle, target);
  }

  @override
  Future<void> deleteDocument(int documentId) async {
    final doc = await _dao.documentById(documentId);
    if (doc == null) return;
    await _dao.deleteDocument(documentId);
    final file = File(doc.filePath);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<StudentHistory> getHistory(int studentId) async {
    final attendance = await _dao.attendanceOf(studentId);
    final vouchers = await _dao.vouchersOf(studentId);
    final results = await _dao.resultsOf(studentId);
    return StudentHistory(
      attendance: [
        for (final a in attendance)
          AttendanceRecord(date: DateTime.parse(a.date), status: a.status, note: a.note),
      ],
      fees: [
        for (final v in vouchers)
          FeeRecord(
            receiptNo: v.receiptNo,
            date: DateTime.parse(v.date),
            forMonth: v.forMonth,
            total: v.total,
            paidAmount: v.paidAmount,
            status: v.status,
          ),
      ],
      results: [
        for (final r in results)
          ResultRecord(
            examName: r.exam.name,
            subjectName: r.subject.name,
            obtainedMarks: r.result.obtainedMarks,
            totalMarks: r.subject.totalMarks,
          ),
      ],
    );
  }

  String? _iso(DateTime? date) => date == null ? null : AppDateUtils.toIso(date);

}
