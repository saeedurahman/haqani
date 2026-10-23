import 'package:intl/intl.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../admissions/domain/admissions_repository.dart';
import '../../attendance/domain/attendance_repository.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exams_repository.dart';
import '../../exams/domain/result_calculator.dart';
import '../../fees/domain/fee_models.dart';
import '../../fees/domain/fees_repository.dart';
import '../../students/domain/student.dart';
import '../../students/domain/student_extras.dart';
import '../../students/domain/students_repository.dart';
import '../domain/report_models.dart';
import '../domain/reports_repository.dart';

/// Builds every report from the data the other modules already keep.
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({
    required this._students,
    required this._admissions,
    required this._attendance,
    required this._fees,
    required this._exams,
  });

  final StudentsRepository _students;
  final AdmissionsRepository _admissions;
  final AttendanceRepository _attendance;
  final FeesRepository _fees;
  final ExamsRepository _exams;

  static const _id = ReportColumn('ID', flex: 1);
  static const _name = ReportColumn('Student', flex: 3);

  @override
  Future<List<ClassOption>> getClassOptions() => _students.getClassOptions();

  @override
  Future<List<Exam>> getExamOptions() => _exams.getExams();

  @override
  Future<List<Student>> findStudents(String query) async {
    if (query.trim().isEmpty) return const [];
    final found = await _students.searchStudents(query: query);
    return found.take(30).toList();
  }

  @override
  Future<SchoolInfo> getSchoolInfo() => _exams.getSchoolInfo();

  // ---- students ----

  @override
  Future<ReportDocument> studentsReport() async {
    final students = await _students.searchStudents();
    final classes = await _students.getClassOptions();

    int boys(Iterable<Student> s) => s.where((x) => x.gender != 'female').length;
    int girls(Iterable<Student> s) => s.where((x) => x.gender == 'female').length;

    final byClass = <int?, List<Student>>{};
    for (final s in students) {
      (byClass[s.classId] ??= []).add(s);
    }
    final classRows = <List<String>>[];
    final sectionRows = <List<String>>[];
    for (final c in [...classes.map((c) => (c.id, c.name)), (null, 'No class')]) {
      final list = byClass[c.$1] ?? const <Student>[];
      if (c.$1 == null && list.isEmpty) continue;
      classRows.add([c.$2, '${boys(list)}', '${girls(list)}', '${list.length}']);

      final bySection = <String, List<Student>>{};
      for (final s in list) {
        (bySection[s.sectionName ?? 'No section'] ??= []).add(s);
      }
      final names = bySection.keys.toList()..sort();
      for (final n in names) {
        final inSection = bySection[n]!;
        sectionRows.add([c.$2, n, '${boys(inSection)}', '${girls(inSection)}', '${inSection.length}']);
      }
    }
    classRows.add(['Total', '${boys(students)}', '${girls(students)}', '${students.length}']);

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

  // ---- admissions ----

  @override
  Future<ReportDocument> admissionsReport({DateTime? from, DateTime? to}) async {
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

  // ---- attendance ----

  @override
  Future<ReportDocument> attendanceReport({
    required int classId,
    int? sectionId,
    required int year,
    required int month,
  }) async {
    final classes = await _students.getClassOptions();
    final selected = classes.where((c) => c.id == classId).firstOrNull;
    if (selected == null) throw const ReportsException('Choose a class.');
    final section = selected.sections.where((s) => s.id == sectionId).firstOrNull;
    final rows = await _attendance.getMonthlyReport(classId, sectionId, year, month);

    final withDays = rows.where((r) => r.markedDays > 0).toList();
    final average = withDays.isEmpty
        ? '-'
        : '${(withDays.fold<int>(0, (s, r) => s + r.percent) / withDays.length).round()}%';

    return ReportDocument(
      title: 'Attendance Report',
      subtitle: '${selected.name}${section == null ? '' : ' - Section ${section.name}'}, '
          '${DateFormat('MMMM yyyy').format(DateTime(year, month))}',
      stats: [
        ReportStat('Students', '${rows.length}'),
        ReportStat('Average attendance', average),
      ],
      tables: [
        ReportTable(
          columns: const [
            _id,
            _name,
            ReportColumn('Present', type: ColumnType.number),
            ReportColumn('Absent', type: ColumnType.number),
            ReportColumn('Leave', type: ColumnType.number),
            ReportColumn('Days marked', type: ColumnType.number),
            ReportColumn('Attendance', type: ColumnType.number),
          ],
          rows: [
            for (final r in rows)
              [
                r.admissionNo,
                r.name,
                '${r.present}',
                '${r.absent}',
                '${r.leave}',
                '${r.markedDays}',
                r.markedDays == 0 ? '-' : '${r.percent}%',
              ],
          ],
        ),
      ],
    );
  }

  // ---- fees ----

  @override
  Future<ReportDocument> feesReport({required String month, int? classId, String? status}) async {
    final classes = await _students.getClassOptions();
    final scope = classId == null ? classes : classes.where((c) => c.id == classId).toList();

    final all = <FeeVoucher>[];
    for (final c in scope) {
      all.addAll(await _fees.getVouchers(month: month, classId: c.id));
    }
    final vouchers = status == null ? all : all.where((v) => v.status == status).toList();

    final billed = vouchers.fold<int>(0, (s, v) => s + v.total);
    final collected = vouchers.fold<int>(0, (s, v) => s + v.paidAmount);
    final monthName = DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'));
    final classText = classId == null ? 'All classes' : (scope.firstOrNull?.name ?? '');
    final statusText = status == null ? 'all vouchers' : '${FeeStatus.label(status).toLowerCase()} only';

    return ReportDocument(
      title: 'Fee Report',
      subtitle: '$monthName  |  $classText  |  $statusText',
      stats: [
        ReportStat('Vouchers', '${vouchers.length}'),
        ReportStat('Billed', MoneyUtils.format(billed)),
        ReportStat('Collected', MoneyUtils.format(collected)),
        ReportStat('Pending', MoneyUtils.format(billed - collected)),
      ],
      tables: [
        ReportTable(
          columns: const [
            _id,
            _name,
            ReportColumn('Class', flex: 2),
            ReportColumn('Total', type: ColumnType.money, flex: 2),
            ReportColumn('Paid', type: ColumnType.money, flex: 2),
            ReportColumn('Balance', type: ColumnType.money, flex: 2),
            ReportColumn('Status', flex: 2),
          ],
          rows: [
            for (final v in vouchers)
              [
                v.student.admissionNo,
                v.student.name,
                v.student.classLabel,
                MoneyUtils.format(v.total),
                MoneyUtils.format(v.paidAmount),
                MoneyUtils.format(v.balance),
                FeeStatus.label(v.status),
              ],
          ],
        ),
      ],
    );
  }

  @override
  Future<ReportDocument> defaultersReport({int? classId}) async {
    final defaulters = await _fees.getDefaulters(classId: classId);
    final pending = defaulters.fold<int>(0, (s, d) => s + d.balance);
    final classes = await _students.getClassOptions();
    final className = classId == null ? 'All classes' : (classes.where((c) => c.id == classId).firstOrNull?.name ?? '');

    return ReportDocument(
      title: 'Fee Defaulters',
      subtitle: '$className  |  ${AppDateUtils.toDisplay(DateTime.now())}',
      stats: [
        ReportStat('Students who owe fee', '${defaulters.length}'),
        ReportStat('Total pending', MoneyUtils.format(pending)),
      ],
      tables: [
        ReportTable(
          columns: const [
            _id,
            _name,
            ReportColumn('Father', flex: 3),
            ReportColumn('Class', flex: 2),
            ReportColumn('Months', type: ColumnType.number),
            ReportColumn('Balance', type: ColumnType.money, flex: 2),
          ],
          rows: [
            for (final d in defaulters)
              [
                d.student.admissionNo,
                d.student.name,
                d.student.fatherName,
                d.student.classLabel,
                '${d.monthsPending}',
                MoneyUtils.format(d.balance),
              ],
          ],
        ),
      ],
    );
  }

  // ---- exam results ----

  @override
  Future<ReportDocument> examResultsReport(int examId) async {
    final MarksSheet sheet;
    try {
      sheet = await _exams.getMarksSheet(examId);
    } on ExamsException catch (e) {
      throw ReportsException(e.message);
    }
    final results = ResultCalculator.compute(sheet.subjects, sheet.students);
    final sorted = [...results]..sort((a, b) {
        if (a.position != null && b.position != null) {
          final c = a.position!.compareTo(b.position!);
          if (c != 0) return c;
        } else if (a.position != null) {
          return -1;
        } else if (b.position != null) {
          return 1;
        }
        return a.student.name.compareTo(b.student.name);
      });

    final complete = results.where((r) => r.isComplete).toList();
    final passed = complete.where((r) => r.status == ResultStatus.pass).length;
    final average = complete.isEmpty
        ? '-'
        : '${(complete.fold<double>(0, (s, r) => s + r.percent) / complete.length).toStringAsFixed(1)}%';

    return ReportDocument(
      title: 'Exam Results',
      subtitle: '${sheet.exam.name}  |  ${sheet.exam.className}'
          '${sheet.exam.date == null ? '' : '  |  ${AppDateUtils.toDisplay(sheet.exam.date!)}'}',
      stats: [
        ReportStat('Students', '${results.length}'),
        ReportStat('Passed', '$passed'),
        ReportStat('Failed', '${complete.length - passed}'),
        ReportStat('Average', average),
      ],
      tables: [
        ReportTable(
          columns: [
            const ReportColumn('Pos', type: ColumnType.number),
            _id,
            const ReportColumn('Student', flex: 3),
            for (final s in sheet.subjects)
              ReportColumn('${s.name} (${s.totalMarks})', type: ColumnType.number, flex: 2),
            const ReportColumn('Total', type: ColumnType.number, flex: 2),
            const ReportColumn('%', type: ColumnType.number),
            const ReportColumn('Grade'),
            const ReportColumn('Result', flex: 2),
          ],
          rows: [
            for (final r in sorted)
              [
                r.position == null ? '-' : '${r.position}',
                r.student.admissionNo,
                r.student.name,
                for (final s in sheet.subjects) r.student.marks[s.id]?.toString() ?? '-',
                r.status == ResultStatus.notEntered ? '-' : '${r.obtained}/${r.maxMarks}',
                r.status == ResultStatus.notEntered ? '-' : r.percent.toStringAsFixed(1),
                r.grade,
                r.status.label,
              ],
          ],
        ),
      ],
    );
  }

  // ---- student history ----

  @override
  Future<ReportDocument> studentHistoryReport(int studentId) async {
    final student = await _students.getStudent(studentId);
    if (student == null) throw const ReportsException('This student was not found.');
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
    final due = fees.where((f) => !f.carriedForward).fold<int>(0, (s, f) => s + f.balance);

    return ReportDocument(
      title: 'Student History',
      subtitle: '${student.name}  |  ID ${student.admissionNo}'
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
                f.receiptNo.isEmpty ? '-' : f.receiptNo,
                MoneyUtils.format(f.total),
                MoneyUtils.format(f.paidAmount),
                MoneyUtils.format(f.balance),
                f.carriedForward ? 'Carried forward' : FeeStatus.label(f.status),
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
