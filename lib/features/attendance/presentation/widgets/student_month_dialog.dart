import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/attendance_models.dart';
import 'status_colors.dart';
import 'summary_chips.dart';

/// Day by day attendance of one student for one month.
class StudentMonthDialog extends StatelessWidget {
  const StudentMonthDialog({super.key, required this.row, required this.month});

  final MonthlyAttendanceRow row;
  final DateTime month;

  static Future<void> show(BuildContext context, MonthlyAttendanceRow row, DateTime month) {
    return showDialog<void>(
      context: context,
      builder: (_) => StudentMonthDialog(row: row, month: month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              SummaryChips(
                total: row.markedDays,
                present: row.present,
                absent: row.absent,
                leave: row.leave,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var day = 1; day <= daysInMonth; day++)
                    _DayCell(day: day, status: row.days[day]),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.status});

  final int day;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = attendanceColor(status);
    final marked = status != null;
    return Tooltip(
      message: AttendanceStatus.label(status),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: marked ? color : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: marked ? color : AppColors.border),
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: marked ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
