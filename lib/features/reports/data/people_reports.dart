import 'package:intl/intl.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../admissions/domain/admissions_repository.dart';
import '../../exams/domain/exams_repository.dart';
import '../../fees/domain/fee_models.dart';
import '../../fees/domain/fees_repository.dart';
import '../../students/domain/student.dart';
import '../../students/domain/students_repository.dart';
import '../domain/report_models.dart';

/// The students, new admissions and student history reports.
class PeopleReports {
  PeopleReports({
    required this._students,
    required this._admissions,
    required this._fees,
    required this._exams,
  });

  final StudentsRepository _students;
  final AdmissionsRepository _admissions;
  final FeesRepository _fees;
  final ExamsRepository _exams;

  Future<ReportDocument> studentsReport() async {
    final students = await _students.searchStudents();
    final classes = await _students.getClassOptions();

    int boys(Iterable<Student> s) =>
        s.where((x) => x.gender != 'female').length;
    int girls(Iterable<Student> s) =>
        s.where((x) => x.gender == 'female').length;

    final byClass = <int?, List<Student>>{};
    for (final s in students) {
      (byClass[s.classId] ??= []).add(s);
    }
    final classRows = <List<String>>[];
    final sectionRows = <List<String>>[];
    for (final c in [
      ...classes.map((c) => (c.id, c.name)),
      (null, 'No class'),
    ]) {
      final list = byClass[c.$1] ?? const <Student>[];
      if (c.$1 == null && list.isEmpty) continue;
      classRows.add([
        c.$2,
        '${boys(list)}',
        '${girls(list)}',
        '${list.length}',
      ]);

      final bySection = <String, List<Student>>{};
      for (final s in list) {
        (bySection[s.sectionName ?? 'No section'] ??= []).add(s);
      }
      final names = bySection.keys.toList()..sort();
      for (final n in names) {
        final inSection = bySection[n]!;
        sectionRows.add([
          c.$2,
          n,
          '${boys(inSection)}',
          '${girls(inSection)}',
          '${inSection.length}',
        ]);
      }
    }
    classRows.add([
      'Total',
      '${boys(students)}',
      '${girls(students)}',
      '${students.length}',
    ]);

    return ReportDocument(
      title: 'Students Report',
      subtitle: 'Active students on ${AppDateUtils.toDisplay(DateTime.now())}',
      stats: [
        ReportStat('Total students', '${students.length}'),
        ReportStat('Boys', '${boys(students)}'),
        ReportStat('Girls', '${girls(students)}'),
      ],
      tables: [
        ReportTable(
          heading: 'Class-wise students',
          columns: const [
            ReportColumn('Class', flex: 3),
            ReportColumn('Boys', type: ColumnType.number),
            ReportColumn('Girls', type: ColumnType.number),
            ReportColumn('Total', type: ColumnType.number),
          ],
          rows: classRows,
          searchable: false,
          boldLastRow: true,
        ),
        ReportTable(
          heading: 'Section-wise students',
          columns: const [
            ReportColumn('Class', flex: 3),
            ReportColumn('Section', flex: 2),
            ReportColumn('Boys', type: ColumnType.number),
            ReportColumn('Girls', type: ColumnType.number),
            ReportColumn('Total', type: ColumnType.number),
          ],
          rows: sectionRows,
          searchable: false,
        ),
      ],
    );
  }

  Future<ReportDocument> admissionsReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final students = await _admissions.getAdmissions(from: from, to: to);
    String day(DateTime? d) => d == null ? '' : AppDateUtils.toDisplay(d);
    final range = from == null && to == null
        ? 'All dates'
        : '${from == null ? 'Start' : day(from)} to ${to == null ? 'today' : day(to)}';

    return ReportDocument(
      title: 'New Admissions',
      subtitle: range,
      stats: [ReportStat('Students admitted', '${students.length}')],
      tables: [
        ReportTable(
          columns: const [
            ReportColumn('No.', flex: 1),
            ReportColumn('Student', flex: 3),
            ReportColumn('Father', flex: 3),
            ReportColumn('Class', flex: 2),
            ReportColumn('Admission date', flex: 2),
            ReportColumn('Status', flex: 1),
          ],
          rows: [
            for (final s in students)
              [
                s.admissionNo,
                s.name,
                s.fatherName,
                s.classLabel,
                day(s.admissionDate),
                s.isActive ? 'Active' : 'Left',
              ],
          ],
        ),
      ],
    );
  }

  Future<ReportDocument> studentHistoryReport(int studentId) async {
    final student = await _students.getStudent(studentId);
    if (student == null) {
      throw const ReportsException('This student was not found.');
    }
    final history = await _students.getHistory(studentId);
    final fees = await _fees.getHistory(studentId);
    final exams = await _exams.getStudentHistory(studentId);

    String day(DateTime? d) => d == null ? '-' : AppDateUtils.toDisplay(d);

    final byMonth = <String, List<String>>{};
    for (final a in history.attendance) {
      (byMonth[AppDateUtils.toMonth(a.date)] ??= []).add(a.status);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    final attendanceRows = [
      for (final m in months)
        () {
          final list = byMonth[m]!;
          final present = list.where((s) => s == 'present').length;
          return [
            DateFormat('MMMM yyyy').format(DateTime.parse('$m-01')),
            '$present',
            '${list.where((s) => s == 'absent').length}',
            '${list.where((s) => s == 'leave').length}',
            '${(present * 100 / list.length).round()}%',
          ];
        }(),
    ];
    final totalPresent = history.countAttendance('present');
    final overall = history.attendance.isEmpty
        ? '-'
        : '${(totalPresent * 100 / history.attendance.length).round()}%';
    final due = fees
        .where((f) => !f.carriedForward)
        .fold<int>(0, (s, f) => s + f.balance);

    return ReportDocument(
      title: 'Student History',
      subtitle:
          '${student.name}  |  ID ${student.admissionNo}'
          '${student.fatherName.isEmpty ? '' : '  |  Father: ${student.fatherName}'}',
      stats: [
        ReportStat('Class', student.classLabel),
        ReportStat('Admission date', day(student.admissionDate)),
        ReportStat('Status', student.isActive ? 'Active' : 'Left'),
        ReportStat('Attendance', overall),
        ReportStat('Fee due', MoneyUtils.format(due)),
      ],
      tables: [
        ReportTable(
          heading: 'Attendance by month',
          columns: const [
            ReportColumn('Month', flex: 3),
            ReportColumn('Present', type: ColumnType.number),
            ReportColumn('Absent', type: ColumnType.number),
            ReportColumn('Leave', type: ColumnType.number),
            ReportColumn('Attendance', type: ColumnType.number),
          ],
          rows: attendanceRows,
          searchable: false,
        ),
        ReportTable(
          heading: 'Fee history',
          columns: const [
            ReportColumn('Month', flex: 2),
            ReportColumn('Receipt', flex: 2),
            ReportColumn('Total', type: ColumnType.money, flex: 2),
            ReportColumn('Paid', type: ColumnType.money, flex: 2),
            ReportColumn('Balance', type: ColumnType.money, flex: 2),
            ReportColumn('Status', flex: 2),
          ],
          rows: [
            for (final f in fees)
              [
                f.forMonth,
                f.receiptNos.isEmpty ? '-' : f.receiptNos,
                MoneyUtils.format(f.total),
                MoneyUtils.format(f.paidAmount),
                MoneyUtils.format(f.balance),
                f.carriedForward
                    ? 'Carried forward'
                    : FeeStatus.label(f.status),
              ],
          ],
          searchable: false,
        ),
        ReportTable(
          heading: 'Exam results',
          columns: const [
            ReportColumn('Exam', flex: 3),
            ReportColumn('Class', flex: 2),
            ReportColumn('Total', type: ColumnType.number, flex: 2),
            ReportColumn('%', type: ColumnType.number),
            ReportColumn('Grade'),
            ReportColumn('Position', type: ColumnType.number),
            ReportColumn('Result', flex: 2),
          ],
          rows: [
            for (final e in exams)
              [
                e.examName,
                e.className,
                '${e.obtained}/${e.maxMarks}',
                e.percent.toStringAsFixed(1),
                e.grade,
                e.position == null ? '-' : '${e.position}',
                e.status.label,
              ],
          ],
          searchable: false,
        ),
      ],
    );
  }
}
