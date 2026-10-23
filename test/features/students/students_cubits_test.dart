import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/students/domain/student.dart';
import 'package:haqani/features/students/domain/student_extras.dart';
import 'package:haqani/features/students/domain/student_history.dart';
import 'package:haqani/features/students/domain/students_exception.dart';
import 'package:haqani/features/students/domain/students_repository.dart';
import 'package:haqani/features/students/presentation/cubit/student_detail_cubit.dart';
import 'package:haqani/features/students/presentation/cubit/student_detail_state.dart';
import 'package:haqani/features/students/presentation/cubit/student_form_cubit.dart';
import 'package:haqani/features/students/presentation/cubit/student_form_state.dart';
import 'package:haqani/features/students/presentation/cubit/students_cubit.dart';
import 'package:haqani/features/students/presentation/cubit/students_state.dart';

class _FakeRepository implements StudentsRepository {
  List<Student> students = const [
    Student(id: 1, admissionNo: '1', name: 'Ali'),
    Student(id: 2, admissionNo: '2', name: 'Sara'),
  ];
  bool fail = false;
  String? saveError;
  Student? saved;
  String? lastQuery;
  int? lastClassId;
  bool? lastIncludeLeft;
  DateTime? leftOn;
  bool reactivated = false;
  final docs = <StudentDocumentItem>[];

  @override
  Future<List<Student>> searchStudents({
    String query = '',
    int? classId,
    bool includeLeft = false,
  }) async {
    if (fail) throw Exception('db');
    lastQuery = query;
    lastClassId = classId;
    lastIncludeLeft = includeLeft;
    return students;
  }

  @override
  Future<Student?> getStudent(int id) async =>
      students.where((s) => s.id == id).firstOrNull;

  @override
  Future<int> saveStudent(Student student) async {
    if (saveError != null) throw StudentsException(saveError!);
    if (fail) throw Exception('db');
    saved = student;
    return 9;
  }

  @override
  Future<void> markAsLeft(int id, DateTime leavingDate) async => leftOn = leavingDate;

  @override
  Future<void> reactivate(int id) async => reactivated = true;

  @override
  Future<String> suggestAdmissionNo() async => '3';

  @override
  Future<List<ClassOption>> getClassOptions() async =>
      const [ClassOption(id: 1, name: 'Class 1')];

  @override
  Future<List<StudentDocumentItem>> getDocuments(int studentId) async => [...docs];

  @override
  Future<void> addDocument(int studentId, String title, String sourcePath) async {
    if (saveError != null) throw StudentsException(saveError!);
    docs.add(StudentDocumentItem(id: docs.length + 1, title: title, filePath: sourcePath));
  }

  @override
  Future<void> deleteDocument(int documentId) async =>
      docs.removeWhere((d) => d.id == documentId);

  @override
  Future<StudentHistory> getHistory(int studentId) async => const StudentHistory();
}

void main() {
  late _FakeRepository repo;

  setUp(() => repo = _FakeRepository());

  group('StudentsCubit', () {
    test('load emits loading then success with students and classes', () async {
      final cubit = StudentsCubit(repo);
      final statuses = <StudentsStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statuses.first, StudentsStatus.loading);
      expect(statuses.last, StudentsStatus.success);
      expect(cubit.state.students, hasLength(2));
      expect(cubit.state.classes.single.name, 'Class 1');
      await cubit.close();
    });

    test('load failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = StudentsCubit(repo);

      await cubit.load();

      expect(cubit.state.status, StudentsStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });

    test('search, class filter and show-left pass through to the repository', () async {
      final cubit = StudentsCubit(repo);
      await cubit.load();

      await cubit.search('ali');
      await cubit.filterByClass(1);
      await cubit.showLeft(true);

      expect(repo.lastQuery, 'ali');
      expect(repo.lastClassId, 1);
      expect(repo.lastIncludeLeft, isTrue);
      expect(cubit.state.hasFilter, isTrue);

      await cubit.filterByClass(null);
      expect(repo.lastClassId, isNull);
      expect(cubit.state.classFilter, isNull);
      await cubit.close();
    });
  });

  group('StudentFormCubit', () {
    test('new student: loads classes and the suggested admission number', () async {
      final cubit = StudentFormCubit(repo);

      await cubit.load();

      expect(cubit.state.status, StudentFormStatus.ready);
      expect(cubit.state.suggestedAdmissionNo, '3');
      expect(cubit.state.isEditing, isFalse);
      await cubit.close();
    });

    test('edit: loads the student, and fails clearly when it is missing', () async {
      final cubit = StudentFormCubit(repo);
      await cubit.load(studentId: 1);
      expect(cubit.state.student?.name, 'Ali');
      expect(cubit.state.isEditing, isTrue);

      final missing = StudentFormCubit(repo);
      await missing.load(studentId: 99);
      expect(missing.state.status, StudentFormStatus.failure);
      await cubit.close();
      await missing.close();
    });

    test('save success returns the saved id', () async {
      final cubit = StudentFormCubit(repo);
      await cubit.load();

      await cubit.save(const Student(admissionNo: '3', name: 'Zain'));

      expect(cubit.state.status, StudentFormStatus.saved);
      expect(cubit.state.savedId, 9);
      expect(repo.saved?.name, 'Zain');
      await cubit.close();
    });

    test('a refused save goes back to ready with the reason', () async {
      repo.saveError = 'Admission number 3 is already used.';
      final cubit = StudentFormCubit(repo);
      await cubit.load();

      await cubit.save(const Student(admissionNo: '3', name: 'Zain'));

      expect(cubit.state.status, StudentFormStatus.ready);
      expect(cubit.state.errorMessage, 'Admission number 3 is already used.');
      await cubit.close();
    });

    test('an unexpected save error shows a friendly message', () async {
      final cubit = StudentFormCubit(repo);
      await cubit.load();
      repo.fail = true;

      await cubit.save(const Student(admissionNo: '3', name: 'Zain'));

      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('StudentDetailCubit', () {
    final day = DateTime(2026, 6, 1);

    test('load fills student, documents and history', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);

      await cubit.load(1);

      expect(cubit.state.status, StudentDetailStatus.success);
      expect(cubit.state.student?.name, 'Ali');
      await cubit.close();
    });

    test('missing student gives a failure state', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);

      await cubit.load(99);

      expect(cubit.state.status, StudentDetailStatus.failure);
      await cubit.close();
    });

    test('markAsLeft uses today and reports success', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);
      await cubit.load(1);

      await cubit.markAsLeft();

      expect(repo.leftOn, day);
      expect(cubit.state.feedback, 'Ali is marked as left.');
      expect(cubit.state.feedbackIsError, isFalse);
      await cubit.close();
    });

    test('reactivate reports success', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);
      await cubit.load(1);

      await cubit.reactivate();

      expect(repo.reactivated, isTrue);
      expect(cubit.state.feedback, 'Ali is active again.');
      await cubit.close();
    });

    test('adds and removes a document, refreshing the list', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);
      await cubit.load(1);

      await cubit.addDocument('B-Form', '/tmp/bform.pdf');
      expect(cubit.state.documents.single.title, 'B-Form');

      await cubit.deleteDocument(1);
      expect(cubit.state.documents, isEmpty);
      await cubit.close();
    });

    test('a refused document shows the reason as an error', () async {
      final cubit = StudentDetailCubit(repo, clock: () => day);
      await cubit.load(1);
      repo.saveError = 'The file was not found.';

      await cubit.addDocument('X', '/nope');

      expect(cubit.state.feedback, 'The file was not found.');
      expect(cubit.state.feedbackIsError, isTrue);
      await cubit.close();
    });
  });
}
