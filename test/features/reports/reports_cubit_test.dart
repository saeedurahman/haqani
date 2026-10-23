import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/reports/domain/report_kind.dart';
import 'package:haqani/features/reports/domain/report_models.dart';
import 'package:haqani/features/reports/domain/reports_repository.dart';
import 'package:haqani/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:haqani/features/reports/presentation/cubit/reports_state.dart';
import 'package:haqani/features/students/domain/student.dart';
import 'package:haqani/features/students/domain/student_extras.dart';

const _doc = ReportDocument(
  title: 'T',
  tables: [
    ReportTable(
      columns: [ReportColumn('Name'), ReportColumn('Fee', type: ColumnType.money)],
      rows: [
        ['Ali', 'Rs 1,500'],
        ['Sara', 'Rs 2,000'],
      ],
    ),
  ],
);

class _FakeRepository implements ReportsRepository {
  bool fail = false;
  String? refuse;
  final calls = <String>[];

  Future<ReportDocument> _doc_(String call) async {
    if (fail) throw Exception('db');
    if (refuse != null) throw ReportsException(refuse!);
    calls.add(call);
    return _doc;
  }

  @override
  Future<List<ClassOption>> getClassOptions() async {
    if (fail) throw Exception('db');
    return const [ClassOption(id: 1, name: 'Class 1'), ClassOption(id: 2, name: 'Class 2')];
  }

  @override
  Future<List<Exam>> getExamOptions() async =>
      const [Exam(id: 7, name: 'Annual', classId: 1, className: 'Class 1')];

  @override
  Future<List<Student>> findStudents(String query) async =>
      const [Student(id: 3, admissionNo: '3', name: 'Zain')];

  @override
  Future<SchoolInfo> getSchoolInfo() async => const SchoolInfo(name: 'Test');

  @override
  Future<ReportDocument> studentsReport() => _doc_('students');

  @override
  Future<ReportDocument> admissionsReport({DateTime? from, DateTime? to}) =>
      _doc_('admissions $from $to');

  @override
  Future<ReportDocument> attendanceReport({
    required int classId,
    int? sectionId,
    required int year,
    required int month,
  }) =>
      _doc_('attendance $classId $sectionId $year-$month');

  @override
  Future<ReportDocument> feesReport({required String month, int? classId, String? status}) =>
      _doc_('fees $month $classId $status');

  @override
  Future<ReportDocument> defaultersReport({int? classId}) => _doc_('defaulters $classId');

  @override
  Future<ReportDocument> examResultsReport(int examId) => _doc_('exam $examId');

  @override
  Future<ReportDocument> studentHistoryReport(int studentId) => _doc_('history $studentId');
}

void main() {
  final now = DateTime(2026, 5, 12);
  late _FakeRepository repo;

  setUp(() => repo = _FakeRepository());

  ReportsCubit make(ReportKind kind) => ReportsCubit(repo, kind, clock: () => now);

  test('students report loads at once', () async {
    final cubit = make(ReportKind.students);

    await cubit.load();

    expect(cubit.state.status, ReportsStatus.success);
    expect(repo.calls, ['students']);
    expect(cubit.state.document, _doc);
    await cubit.close();
  });

  test('admissions starts with this month up to today and follows the dates', () async {
    final cubit = make(ReportKind.admissions);

    await cubit.load();
    expect(repo.calls.last, 'admissions ${DateTime(2026, 5)} ${DateTime(2026, 5, 12)}');

    await cubit.setRange(from: DateTime(2026, 1, 1));
    expect(repo.calls.last, 'admissions ${DateTime(2026, 1, 1)} null');
    await cubit.close();
  });

  test('attendance picks the first class and the current month; class change clears the section',
      () async {
    final cubit = make(ReportKind.attendance);

    await cubit.load();
    expect(repo.calls.last, 'attendance 1 null 2026-5');

    await cubit.selectSection(10);
    expect(repo.calls.last, 'attendance 1 10 2026-5');
    await cubit.selectClass(2);
    expect(repo.calls.last, 'attendance 2 null 2026-5');
    await cubit.close();
  });

  test('months move back, but never into the future', () async {
    final cubit = make(ReportKind.fees);
    await cubit.load();
    expect(repo.calls.last, 'fees 2026-05 null null');

    await cubit.moveMonth(-5);
    expect(repo.calls.last, 'fees 2025-12 null null');
    await cubit.moveMonth(5);
    await cubit.moveMonth(1);
    expect(cubit.state.month, DateTime(2026, 5));
    await cubit.close();
  });

  test('fee reports start with all classes and take class and status choices', () async {
    final cubit = make(ReportKind.fees);
    await cubit.load();
    expect(cubit.state.classId, isNull);

    await cubit.selectClass(2);
    await cubit.setFeeStatus('unpaid');
    expect(repo.calls.last, 'fees 2026-05 2 unpaid');

    await cubit.setFeeStatus(null);
    await cubit.selectClass(null);
    expect(repo.calls.last, 'fees 2026-05 null null');
    await cubit.close();
  });

  test('defaulters filter by class', () async {
    final cubit = make(ReportKind.defaulters);
    await cubit.load();

    await cubit.selectClass(1);

    expect(repo.calls, ['defaulters null', 'defaulters 1']);
    await cubit.close();
  });

  test('exam results wait for an exam to be chosen', () async {
    final cubit = make(ReportKind.examResults);

    await cubit.load();
    expect(cubit.state.needsChoice, isTrue);
    expect(cubit.state.document, isNull);
    expect(cubit.state.exams.single.name, 'Annual');
    expect(repo.calls, isEmpty);

    await cubit.selectExam(7);
    expect(repo.calls, ['exam 7']);
    expect(cubit.state.needsChoice, isFalse);
    await cubit.close();
  });

  test('student history: search, pick, and clear', () async {
    final cubit = make(ReportKind.studentHistory);
    await cubit.load();
    expect(cubit.state.needsChoice, isTrue);

    await cubit.searchStudents('zain');
    expect(cubit.state.studentMatches.single.name, 'Zain');

    await cubit.selectStudent(cubit.state.studentMatches.single);
    expect(repo.calls, ['history 3']);
    expect(cubit.state.studentMatches, isEmpty);

    await cubit.selectStudent(null);
    expect(cubit.state.document, isNull);
    expect(cubit.state.needsChoice, isTrue);
    await cubit.close();
  });

  test('search filters what is visible and what is exported', () async {
    final cubit = make(ReportKind.students);
    await cubit.load();

    cubit.search('sara');

    expect(cubit.state.visibleDocument!.tables.first.rows, [
      ['Sara', 'Rs 2,000'],
    ]);
    expect(cubit.state.document!.tables.first.rows, hasLength(2));
    final csv = String.fromCharCodes(cubit.csvBytes()!);
    expect(csv, contains('2000'));
    expect(csv.contains('1500'), isFalse);
    expect(cubit.csvFileName(), 'students_report_2026-05-12.csv');
    await cubit.close();
  });

  test('csv is not available before a report exists', () async {
    final cubit = make(ReportKind.studentHistory);
    await cubit.load();

    expect(cubit.csvBytes(), isNull);
    await cubit.close();
  });

  test('a refused report shows the reason; a database error is friendly', () async {
    final cubit = make(ReportKind.students);
    repo.refuse = 'Choose a class.';

    await cubit.load();
    expect(cubit.state.status, ReportsStatus.failure);
    expect(cubit.state.errorMessage, 'Choose a class.');

    repo.refuse = null;
    repo.fail = true;
    await cubit.load();
    expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
    await cubit.close();
  });
}
