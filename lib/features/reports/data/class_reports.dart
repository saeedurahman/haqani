import 'package:intl/intl.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../attendance/domain/attendance_repository.dart';
import '../../exams/domain/exam_models.dart';
import '../../exams/domain/exams_repository.dart';
import '../../exams/domain/result_calculator.dart';
import '../../students/domain/students_repository.dart';
import '../domain/report_models.dart';
import 'report_columns.dart';

/// The attendance and exam results reports.
class ClassReports {
  ClassReports(this._students, this._attendance, this._exams);

  final StudentsRepository _students;
  final AttendanceRepository _attendance;
  final ExamsRepository _exams;

  Future<ReportDocument> attendanceReport({
    required int classId,
    int? sectionId,
    required int year,
    required int month,
  }) async {
    final classes = await _students.getClassOptions();
    final selected = classes.where((c) => c.id == classId).firstOrNull;
    if (selected == null) throw const ReportsException('Choose a class.');
    final section = selected.sections
        .where((s) => s.id == sectionId)
        .firstOrNull;
    final rows = await _attendance.getMonthlyReport(
      classId,
      sectionId,
      year,
      month,
    );

    final withDays = rows.where((r) => r.markedDays > 0).toList();
    final average = withDays.isEmpty
        ? '-'
        : '${(withDays.fold<int>(0, (s, r) => s + r.percent) / withDays.length).round()}%';

    return ReportDocument(
      title: 'Attendance Report',
      subtitle:
          '${selected.name}${section == null ? '' : ' - Section ${section.name}'}, '
          '${DateFormat('MMMM yyyy').format(DateTime(year, month))}',
      stats: [
        ReportStat('Students', '${rows.length}'),
        ReportStat('Average attendance', average),
      ],
      tables: [
        ReportTable(
          columns: const [
            ReportColumns.id,
            ReportColumns.student,
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

  Future<ReportDocument> examResultsReport(int examId) async {
    final MarksSheet sheet;
    try {
      sheet = await _exams.getMarksSheet(examId);
    } on ExamsException catch (e) {
      throw ReportsException(e.message);
    }
    final results = ResultCalculator.compute(sheet.subjects, sheet.students);
    final sorted = [...results]
      ..sort((a, b) {
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
      subtitle:
          '${sheet.exam.name}  |  ${sheet.exam.className}'
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
            ReportColumns.id,
            const ReportColumn('Student', flex: 3),
            for (final s in sheet.subjects)
              ReportColumn(
                '${s.name} (${s.totalMarks})',
                type: ColumnType.number,
                flex: 2,
              ),
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
                for (final s in sheet.subjects)
                  r.student.marks[s.id]?.toString() ?? '-',
                r.status == ResultStatus.notEntered
                    ? '-'
                    : '${r.obtained}/${r.maxMarks}',
                r.status == ResultStatus.notEntered
                    ? '-'
                    : r.percent.toStringAsFixed(1),
                r.grade,
                r.status.label,
              ],
          ],
        ),
      ],
    );
  }
}
