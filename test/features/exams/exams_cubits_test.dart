import 'package:flutter_test/flutter_test.dart';
import '../../support/fake_whatsapp.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/exams/domain/exams_repository.dart';
import 'package:haqani/features/exams/domain/result_calculator.dart';
import 'package:haqani/features/exams/domain/result_card.dart';
import 'package:haqani/features/exams/domain/result_card_pdf_service.dart';
import 'package:haqani/features/exams/presentation/cubit/exams_cubit.dart';
import 'package:haqani/features/exams/presentation/cubit/exams_state.dart';
import 'package:haqani/features/exams/presentation/cubit/marks_cubit.dart';
import 'package:haqani/features/exams/presentation/cubit/marks_state.dart';
import 'package:haqani/features/exams/presentation/cubit/result_card_cubit.dart';
import 'package:haqani/features/exams/presentation/cubit/result_card_state.dart';
import 'package:haqani/features/exams/presentation/cubit/subjects_cubit.dart';
import 'package:haqani/features/students/domain/student_extras.dart';
import 'dart:typed_data';

const _english = Subject(id: 1, classId: 1, name: 'English');
const _math = Subject(id: 2, classId: 1, name: 'Math', totalMarks: 50);

class _FakeRepository implements ExamsRepository {
  bool fail = false;
  String? blockWith;
  List<Exam> exams = const [
    Exam(id: 1, name: 'Annual', classId: 1, className: 'Class 1'),
  ];
  List<Subject> subjects = const [_english, _math];
  Map<int, Map<int, int>> marks = {
    10: {1: 90, 2: 40},
    11: {1: 50},
  };
  List<MarkEntry>? savedMarks;
  Exam? savedExam;
  Subject? savedSubject;
  int? lastClassFilter;
  String? lastQuery;

  void _check() {
    if (fail) throw Exception('db');
    if (blockWith != null) throw ExamsException(blockWith!);
  }

  @override
  Future<List<ClassOption>> getClassOptions() async {
    _check();
    return const [ClassOption(id: 1, name: 'Class 1'), ClassOption(id: 2, name: 'Class 2')];
  }

  @override
  Future<List<Exam>> getExams({int? classId, String query = ''}) async {
    if (fail) throw Exception('db');
    lastClassFilter = classId;
    lastQuery = query;
    return exams;
  }

  @override
  Future<void> saveExam(Exam exam) async {
    _check();
    savedExam = exam;
  }

  @override
  Future<void> deleteExam(int id) async {
    _check();
    exams = [for (final e in exams) if (e.id != id) e];
  }

  @override
  Future<List<Subject>> getSubjects(int classId) async {
    if (fail) throw Exception('db');
    return subjects;
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    _check();
    savedSubject = subject;
  }

  @override
  Future<void> deleteSubject(int id) async {
    _check();
    subjects = [for (final s in subjects) if (s.id != id) s];
  }

  @override
  Future<MarksSheet> getMarksSheet(int examId) async {
    _check();
    return MarksSheet(
      exam: exams.first,
      subjects: subjects,
      students: [
        StudentMarks(studentId: 10, name: 'Ali', admissionNo: '1', marks: marks[10] ?? const {}),
        StudentMarks(studentId: 11, name: 'Sara', admissionNo: '2', marks: marks[11] ?? const {}),
        StudentMarks(studentId: 12, name: 'Zain', admissionNo: '3', marks: marks[12] ?? const {}),
      ],
    );
  }

  @override
  Future<void> saveMarks(int examId, List<MarkEntry> entries) async {
    _check();
    savedMarks = entries;
    for (final e in entries) {
      final m = Map.of(marks[e.studentId] ?? <int, int>{});
      if (e.marks == null) {
        m.remove(e.subjectId);
      } else {
        m[e.subjectId] = e.marks!;
      }
      marks[e.studentId] = m;
    }
  }

  @override
  Future<SchoolInfo> getSchoolInfo() async => const SchoolInfo(name: 'Test School');

  @override
  Future<List<ExamSummary>> getStudentHistory(int studentId) async => const [
        ExamSummary(
          examName: 'Mid Term',
          className: 'Class 1',
          obtained: 50,
          maxMarks: 150,
          percent: 33.3,
          grade: 'E',
          status: ResultStatus.pass,
          position: 2,
        ),
      ];
}

class _FakePdf implements ResultCardPdfService {
  List<ResultCard>? built;

  @override
  Future<Uint8List> build(List<ResultCard> cards) async {
    built = cards;
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  late _FakeRepository repo;

  late FakeWhatsAppService whatsApp;

  setUp(() {
    repo = _FakeRepository();
    whatsApp = FakeWhatsAppService();
  });

  group('ExamsCubit', () {
    test('load gives classes and exams; filter and search go to the repository', () async {
      final cubit = ExamsCubit(repo);

      await cubit.load();
      expect(cubit.state.status, ExamsStatus.success);
      expect(cubit.state.classes, hasLength(2));
      expect(cubit.state.exams.single.name, 'Annual');

      await cubit.filterByClass(2);
      await cubit.search('mid');
      expect(repo.lastClassFilter, 2);
      expect(repo.lastQuery, 'mid');
      expect(cubit.state.hasFilter, isTrue);
      await cubit.close();
    });

    test('create, update and delete report success; blocked delete shows the rule', () async {
      final cubit = ExamsCubit(repo);
      await cubit.load();

      await cubit.saveExam(const Exam(name: 'Mid', classId: 1));
      expect(cubit.state.feedback, 'Exam created.');
      await cubit.saveExam(const Exam(id: 1, name: 'Mid', classId: 1));
      expect(cubit.state.feedback, 'Exam updated.');
      await cubit.deleteExam(1);
      expect(cubit.state.feedback, 'Exam deleted.');
      expect(cubit.state.exams, isEmpty);

      repo.blockWith = 'This exam has marks, so it cannot be deleted.';
      await cubit.deleteExam(1);
      expect(cubit.state.feedback, repo.blockWith);
      expect(cubit.state.feedbackIsError, isTrue);
      await cubit.close();
    });

    test('load failure is friendly', () async {
      repo.fail = true;
      final cubit = ExamsCubit(repo);

      await cubit.load();

      expect(cubit.state.status, ExamsStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('SubjectsCubit', () {
    test('loads the first class, saves with the class id, deletes', () async {
      final cubit = SubjectsCubit(repo);
      await cubit.load();
      expect(cubit.state.classId, 1);
      expect(cubit.state.totalMarks, 150);

      await cubit.save(name: 'Urdu', totalMarks: 80);
      expect(repo.savedSubject?.classId, 1);
      expect(repo.savedSubject?.totalMarks, 80);
      expect(cubit.state.feedback, 'Subject added.');

      await cubit.save(id: 2, name: 'Maths', totalMarks: 50);
      expect(cubit.state.feedback, 'Subject updated.');

      await cubit.delete(2);
      expect(cubit.state.subjects.map((s) => s.name), ['English']);
      await cubit.close();
    });

    test('a refused save shows the reason', () async {
      final cubit = SubjectsCubit(repo);
      await cubit.load();
      repo.blockWith = 'This class already has a subject named "Urdu".';

      await cubit.save(name: 'Urdu', totalMarks: 100);

      expect(cubit.state.feedback, repo.blockWith);
      expect(cubit.state.feedbackIsError, isTrue);
      await cubit.close();
    });

    test('changing class reloads', () async {
      final cubit = SubjectsCubit(repo);
      await cubit.load();

      await cubit.selectClass(2);

      expect(cubit.state.classId, 2);
      await cubit.close();
    });
  });

  group('MarksCubit', () {
    test('load shows the saved marks and results', () async {
      final cubit = MarksCubit(repo);

      await cubit.load(1);

      expect(cubit.state.status, MarksStatus.success);
      expect(cubit.state.hasChanges, isFalse);
      final results = cubit.state.savedResults;
      expect(results[0].status, ResultStatus.pass);
      expect(results[0].position, 1);
      expect(results[1].status, ResultStatus.incomplete);
      expect(results[2].status, ResultStatus.notEntered);
      await cubit.close();
    });

    test('typing a mark updates the live results but not the saved ones', () async {
      final cubit = MarksCubit(repo);
      await cubit.load(1);

      cubit.setMark(11, 2, 45);

      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.liveResults[1].status, ResultStatus.pass);
      expect(cubit.state.liveResults[1].obtained, 95);
      expect(cubit.state.savedResults[1].status, ResultStatus.incomplete);
      await cubit.close();
    });

    test('typing the saved value again, or undoing, leaves no change', () async {
      final cubit = MarksCubit(repo);
      await cubit.load(1);

      cubit.setMark(10, 1, 91);
      expect(cubit.state.hasChanges, isTrue);
      cubit.setMark(10, 1, 90);
      expect(cubit.state.hasChanges, isFalse);

      cubit.setMark(10, 1, null);
      expect(cubit.state.liveResults[0].status, ResultStatus.incomplete);
      cubit.setMark(10, 1, 90);
      expect(cubit.state.hasChanges, isFalse);
      await cubit.close();
    });

    test('a mark above the total is invalid and blocks Save', () async {
      final cubit = MarksCubit(repo);
      await cubit.load(1);

      cubit.setMark(11, 2, 51);

      expect(cubit.state.isInvalid((11, 2)), isTrue);
      expect(cubit.state.hasInvalid, isTrue);
      await cubit.save();
      expect(repo.savedMarks, isNull);

      cubit.setMark(11, 2, 50);
      expect(cubit.state.hasInvalid, isFalse);
      await cubit.close();
    });

    test('save sends only the changed boxes, then reloads with no changes', () async {
      final cubit = MarksCubit(repo);
      await cubit.load(1);
      cubit.setMark(11, 2, 45);
      cubit.setMark(10, 1, null);

      await cubit.save();

      expect(repo.savedMarks, [
        const MarkEntry(studentId: 11, subjectId: 2, marks: 45),
        const MarkEntry(studentId: 10, subjectId: 1),
      ]);
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.feedback, 'Marks saved.');
      expect(cubit.state.savedResults[1].status, ResultStatus.pass);
      expect(cubit.state.isSaving, isFalse);
      await cubit.close();
    });

    test('a refused save keeps the typed marks', () async {
      final cubit = MarksCubit(repo);
      await cubit.load(1);
      cubit.setMark(11, 2, 45);
      repo.blockWith = 'Marks of Math must be from 0 to 50.';

      await cubit.save();

      expect(cubit.state.feedback, repo.blockWith);
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.isSaving, isFalse);
      await cubit.close();
    });

    test('load failure shows the reason', () async {
      repo.blockWith = 'This exam was not found.';
      final cubit = MarksCubit(repo);

      await cubit.load(9);

      expect(cubit.state.status, MarksStatus.failure);
      expect(cubit.state.errorMessage, 'This exam was not found.');
      await cubit.close();
    });
  });

  group('ResultCardCubit', () {
    test('one student: builds the card, the PDF and the history', () async {
      final pdf = _FakePdf();
      final cubit = ResultCardCubit(repo, pdf, whatsApp);

      await cubit.load(1, studentId: 10);

      expect(cubit.state.status, ResultCardStatus.success);
      final card = cubit.state.cards.single;
      expect(card.result.student.name, 'Ali');
      expect(card.result.position, 1);
      expect(card.rankedStudents, 1);
      expect(card.lines.map((l) => (l.name, l.obtained, l.grade)), [('English', 90, 'A+'), ('Math', 40, 'A+')]);
      expect(cubit.state.history.single.examName, 'Mid Term');
      expect(cubit.state.pdfBytes, isNotNull);
      expect(pdf.built, hasLength(1));
      await cubit.close();
    });

    test('whole class: one card for every student who has marks, no history', () async {
      final pdf = _FakePdf();
      final cubit = ResultCardCubit(repo, pdf, whatsApp);

      await cubit.load(1);

      expect(cubit.state.cards.map((c) => c.result.student.name), ['Ali', 'Sara']);
      expect(cubit.state.history, isEmpty);
      await cubit.close();
    });

    test('nothing to print gives a clear message', () async {
      repo.marks = {};
      final cubit = ResultCardCubit(repo, _FakePdf(), whatsApp);

      await cubit.load(1);

      expect(cubit.state.status, ResultCardStatus.failure);
      expect(cubit.state.errorMessage, 'No marks are entered yet, so there is nothing to print.');
      await cubit.close();
    });

    test('unknown student and database errors are friendly', () async {
      final cubit = ResultCardCubit(repo, _FakePdf(), whatsApp);
      await cubit.load(1, studentId: 99);
      expect(cubit.state.errorMessage, 'This student was not found in the exam.');

      repo.fail = true;
      await cubit.load(1, studentId: 10);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('ResultCardCubit WhatsApp', () {
    test('sends the result of one student', () async {
      final cubit = ResultCardCubit(repo, _FakePdf(), whatsApp);
      await cubit.load(1, studentId: 10);

      await cubit.sendWhatsApp();

      expect(whatsApp.sent.single.studentId, 10);
      final body = whatsApp.sent.single.body;
      expect(body, contains('Result of Ali - Annual'));
      expect(body, contains('Marks: 130 / 150'));
      expect(body, contains('Grade: A+'));
      expect(body, contains('Position: 1 of 1'));
      expect(body, contains('Result: Pass'));
      expect(cubit.state.feedback, contains('WhatsApp opened'));
      await cubit.close();
    });

    test('does nothing when the whole class is shown', () async {
      final cubit = ResultCardCubit(repo, _FakePdf(), whatsApp);
      await cubit.load(1);

      await cubit.sendWhatsApp();

      expect(whatsApp.sent, isEmpty);
      await cubit.close();
    });
  });
}
