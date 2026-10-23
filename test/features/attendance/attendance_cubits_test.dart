import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/attendance/domain/attendance_models.dart';
import 'package:haqani/features/attendance/domain/attendance_repository.dart';
import 'package:haqani/features/attendance/presentation/cubit/daily_report_cubit.dart';
import 'package:haqani/features/attendance/presentation/cubit/daily_report_state.dart';
import 'package:haqani/features/attendance/presentation/cubit/mark_attendance_cubit.dart';
import 'package:haqani/features/attendance/presentation/cubit/mark_attendance_state.dart';
import 'package:haqani/features/attendance/presentation/cubit/monthly_report_cubit.dart';
import 'package:haqani/features/attendance/presentation/cubit/monthly_report_state.dart';
import 'package:haqani/features/students/domain/student_extras.dart';

class _FakeRepository implements AttendanceRepository {
  List<ClassOption> classes = const [
    ClassOption(id: 1, name: 'Class 1', sections: [SectionOption(id: 10, name: 'A')]),
    ClassOption(id: 2, name: 'Class 2'),
  ];
  Map<int, List<AttendanceEntry>> sheets = {
    1: const [
      AttendanceEntry(studentId: 1, name: 'Ali', admissionNo: '1'),
      AttendanceEntry(studentId: 2, name: 'Sara', admissionNo: '2'),
    ],
    2: const [],
  };
  bool fail = false;
  bool failSave = false;
  int? lastClassId;
  int? lastSectionId;
  DateTime? lastDate;
  DateTime? savedDate;
  List<AttendanceEntry>? saved;
  (int, int)? lastMonth;

  @override
  Future<List<ClassOption>> getClassOptions() async {
    if (fail) throw Exception('db');
    return classes;
  }

  @override
  Future<List<AttendanceEntry>> getDailySheet(int classId, int? sectionId, DateTime date) async {
    if (fail) throw Exception('db');
    lastClassId = classId;
    lastSectionId = sectionId;
    lastDate = date;
    return sheets[classId] ?? const [];
  }

  @override
  Future<void> saveDailySheet(DateTime date, List<AttendanceEntry> entries) async {
    if (failSave) throw Exception('db');
    savedDate = date;
    saved = entries;
    sheets[1] = entries;
  }

  @override
  Future<List<MonthlyAttendanceRow>> getMonthlyReport(
      int classId, int? sectionId, int year, int month) async {
    if (fail) throw Exception('db');
    lastClassId = classId;
    lastMonth = (year, month);
    return const [MonthlyAttendanceRow(studentId: 1, name: 'Ali', admissionNo: '1')];
  }
}

void main() {
  final now = DateTime(2026, 5, 12, 9, 30);
  late _FakeRepository repo;

  setUp(() => repo = _FakeRepository());

  group('MarkAttendanceCubit', () {
    MarkAttendanceCubit make() => MarkAttendanceCubit(repo, clock: () => now);

    test('load picks the first class, starts today and defaults everyone to present', () async {
      final cubit = make();

      await cubit.load();

      expect(cubit.state.status, MarkAttendanceStatus.success);
      expect(cubit.state.classId, 1);
      expect(cubit.state.date, DateTime(2026, 5, 12));
      expect(cubit.state.entries.map((e) => e.status), ['present', 'present']);
      expect(cubit.state.alreadyMarked, isFalse);
      expect(cubit.state.hasChanges, isTrue, reason: 'defaults are not saved yet');
      await cubit.close();
    });

    test('tapping changes one student and marks all changes everyone', () async {
      final cubit = make();
      await cubit.load();

      cubit.setStatus(2, AttendanceStatus.absent);
      expect(cubit.state.entries.map((e) => e.status), ['present', 'absent']);
      expect(cubit.state.count(AttendanceStatus.absent), 1);

      cubit.markAll(AttendanceStatus.leave);
      expect(cubit.state.entries.map((e) => e.status), ['leave', 'leave']);
      await cubit.close();
    });

    test('save sends the date and entries, then reports success with no changes left', () async {
      final cubit = make();
      await cubit.load();
      cubit.setStatus(2, AttendanceStatus.absent);

      await cubit.save();

      expect(repo.savedDate, DateTime(2026, 5, 12));
      expect(repo.saved!.map((e) => e.status), ['present', 'absent']);
      expect(cubit.state.feedback, 'Attendance saved.');
      expect(cubit.state.feedbackIsError, isFalse);
      expect(cubit.state.alreadyMarked, isTrue);
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.isSaving, isFalse);

      cubit.setStatus(1, AttendanceStatus.leave);
      expect(cubit.state.hasChanges, isTrue);
      await cubit.close();
    });

    test('a saved day loads with its saved statuses and is marked as saved', () async {
      repo.sheets[1] = const [
        AttendanceEntry(studentId: 1, name: 'Ali', admissionNo: '1', status: 'absent'),
        AttendanceEntry(studentId: 2, name: 'Sara', admissionNo: '2', status: 'leave'),
      ];
      final cubit = make();

      await cubit.load();

      expect(cubit.state.entries.map((e) => e.status), ['absent', 'leave']);
      expect(cubit.state.alreadyMarked, isTrue);
      expect(cubit.state.hasChanges, isFalse);
      await cubit.close();
    });

    test('a save error shows a friendly message and keeps the taps', () async {
      final cubit = make();
      await cubit.load();
      cubit.setStatus(1, AttendanceStatus.absent);
      repo.failSave = true;

      await cubit.save();

      expect(cubit.state.feedback, AppStrings.somethingWentWrong);
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.entries.first.status, 'absent');
      await cubit.close();
    });

    test('class, section and date changes reload the sheet; future dates are held at today', () async {
      final cubit = make();
      await cubit.load();

      await cubit.selectClass(2);
      expect(repo.lastClassId, 2);
      expect(cubit.state.entries, isEmpty);

      await cubit.selectClass(1);
      await cubit.selectSection(10);
      expect(repo.lastSectionId, 10);

      await cubit.selectDate(DateTime(2026, 5, 3, 14));
      expect(repo.lastDate, DateTime(2026, 5, 3));

      await cubit.selectDate(DateTime(2026, 6, 1));
      expect(cubit.state.date, DateTime(2026, 5, 12));
      await cubit.close();
    });

    test('changing class clears the section', () async {
      final cubit = make();
      await cubit.load();
      await cubit.selectSection(10);

      await cubit.selectClass(2);

      expect(cubit.state.sectionId, isNull);
      await cubit.close();
    });

    test('no classes gives an empty success state', () async {
      repo.classes = const [];
      final cubit = make();

      await cubit.load();

      expect(cubit.state.status, MarkAttendanceStatus.success);
      expect(cubit.state.classId, isNull);
      expect(cubit.state.entries, isEmpty);
      await cubit.close();
    });

    test('load failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = make();

      await cubit.load();

      expect(cubit.state.status, MarkAttendanceStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('DailyReportCubit', () {
    test('shows saved statuses and counts not marked students', () async {
      repo.sheets[1] = const [
        AttendanceEntry(studentId: 1, name: 'Ali', admissionNo: '1', status: 'present'),
        AttendanceEntry(studentId: 2, name: 'Sara', admissionNo: '2'),
      ];
      final cubit = DailyReportCubit(repo, clock: () => now);

      await cubit.load();

      expect(cubit.state.status, DailyReportStatus.success);
      expect(cubit.state.count('present'), 1);
      expect(cubit.state.count(null), 1);
      await cubit.close();
    });

    test('changes reload; future date is held at today; failure is friendly', () async {
      final cubit = DailyReportCubit(repo, clock: () => now);
      await cubit.load();

      await cubit.selectClass(2);
      expect(repo.lastClassId, 2);
      await cubit.selectSection(null);
      await cubit.selectDate(DateTime(2026, 5, 1));
      expect(repo.lastDate, DateTime(2026, 5, 1));
      await cubit.selectDate(DateTime(2027, 1, 1));
      expect(cubit.state.date, DateTime(2026, 5, 12));

      repo.fail = true;
      await cubit.selectClass(1);
      expect(cubit.state.status, DailyReportStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('MonthlyReportCubit', () {
    test('starts on the current month and loads rows', () async {
      final cubit = MonthlyReportCubit(repo, clock: () => now);

      await cubit.load();

      expect(cubit.state.month, DateTime(2026, 5));
      expect(repo.lastMonth, (2026, 5));
      expect(cubit.state.rows.single.name, 'Ali');
      await cubit.close();
    });

    test('moves back across a year, and never goes past the current month', () async {
      final cubit = MonthlyReportCubit(repo, clock: () => DateTime(2026, 1, 15));
      await cubit.load();

      await cubit.moveMonth(-1);
      expect(cubit.state.month, DateTime(2025, 12));
      expect(repo.lastMonth, (2025, 12));

      await cubit.moveMonth(1);
      expect(cubit.state.month, DateTime(2026, 1));

      await cubit.moveMonth(1);
      expect(cubit.state.month, DateTime(2026, 1), reason: 'cannot go to the future');
      await cubit.close();
    });

    test('failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = MonthlyReportCubit(repo, clock: () => now);

      await cubit.load();

      expect(cubit.state.status, MonthlyReportStatus.failure);
      await cubit.close();
    });
  });

  test('MonthlyAttendanceRow percent uses marked days only', () {
    const row = MonthlyAttendanceRow(
      studentId: 1,
      name: 'Ali',
      admissionNo: '1',
      days: {1: 'present', 2: 'present', 3: 'absent'},
    );
    expect(row.percent, 67);
    expect(row.markedDays, 3);
  });
}
