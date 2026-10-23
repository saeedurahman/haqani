import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/student_history.dart';

Color _attendanceColor(String status) => switch (status) {
      'present' => AppColors.success,
      'absent' => AppColors.danger,
      _ => AppColors.warning,
    };

String _title(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key, required this.history});

  final StudentHistory history;

  @override
  Widget build(BuildContext context) {
    if (history.attendance.isEmpty) {
      return const _TabEmpty(
        icon: Icons.event_available_rounded,
        title: 'No attendance yet',
        message: 'Marked attendance will show here.',
      );
    }
    return Column(
      children: [
        AdaptiveGrid(
          maxColumns: 3,
          minItemWidth: 200,
          children: [
            _Count('Present', history.countAttendance('present'), AppColors.success),
            _Count('Absent', history.countAttendance('absent'), AppColors.danger),
            _Count('Leave', history.countAttendance('leave'), AppColors.warning),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Recent days',
          icon: Icons.event_note_rounded,
          child: Column(
            children: [
              for (final a in history.attendance.take(60))
                _Line(
                  left: AppDateUtils.toDisplay(a.date),
                  middle: a.note,
                  right: StatusChip(label: _title(a.status), color: _attendanceColor(a.status)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeesTab extends StatelessWidget {
  const FeesTab({super.key, required this.history});

  final StudentHistory history;

  @override
  Widget build(BuildContext context) {
    if (history.fees.isEmpty) {
      return const _TabEmpty(
        icon: Icons.payments_rounded,
        title: 'No fee records yet',
        message: 'Fee receipts will show here.',
      );
    }
    final due = history.fees.fold<int>(0, (sum, f) => sum + f.due);
    return Column(
      children: [
        AdaptiveGrid(
          maxColumns: 2,
          minItemWidth: 260,
          children: [
            _Count(
              'Total paid',
              history.fees.fold<int>(0, (sum, f) => sum + f.paidAmount),
              AppColors.success,
              money: true,
            ),
            _Count('Total due', due, due > 0 ? AppColors.danger : AppColors.textMuted, money: true),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Fee history',
          icon: Icons.receipt_long_rounded,
          child: Column(
            children: [
              for (final f in history.fees)
                _Line(
                  left: '${f.forMonth}  -  Receipt ${f.receiptNo}',
                  middle: '${MoneyUtils.format(f.paidAmount)} of ${MoneyUtils.format(f.total)}',
                  right: StatusChip(
                    label: _title(f.status),
                    color: switch (f.status) {
                      'paid' => AppColors.success,
                      'partial' => AppColors.warning,
                      _ => AppColors.danger,
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ResultsTab extends StatelessWidget {
  const ResultsTab({super.key, required this.history});

  final StudentHistory history;

  @override
  Widget build(BuildContext context) {
    if (history.results.isEmpty) {
      return const _TabEmpty(
        icon: Icons.edit_note_rounded,
        title: 'No results yet',
        message: 'Exam results will show here.',
      );
    }
    final byExam = <String, List<ResultRecord>>{};
    for (final r in history.results) {
      byExam.putIfAbsent(r.examName, () => []).add(r);
    }
    return Column(
      children: [
        for (final entry in byExam.entries) ...[
          SectionCard(
            title: entry.key,
            icon: Icons.assignment_turned_in_rounded,
            child: Column(
              children: [
                for (final r in entry.value)
                  _Line(
                    left: r.subjectName,
                    middle: '',
                    right: Text(
                      '${r.obtainedMarks} / ${r.totalMarks}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                const Divider(height: 28),
                _Line(
                  left: 'Total',
                  middle: '',
                  right: Text(
                    '${entry.value.fold<int>(0, (s, r) => s + r.obtainedMarks)} / '
                    '${entry.value.fold<int>(0, (s, r) => s + r.totalMarks)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _TabEmpty extends StatelessWidget {
  const _TabEmpty({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: EmptyState(icon: icon, title: title, message: message),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.value, this.color, {this.money = false});

  final String label;
  final int value;
  final Color color;
  final bool money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            money ? MoneyUtils.format(value) : '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.left, required this.middle, required this.right});

  final String left;
  final String middle;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(left, style: Theme.of(context).textTheme.titleMedium)),
          Expanded(
            flex: 3,
            child: Text(middle, style: Theme.of(context).textTheme.bodyMedium),
          ),
          right,
        ],
      ),
    );
  }
}
