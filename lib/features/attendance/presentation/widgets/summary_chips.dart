import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/attendance_models.dart';
import 'status_colors.dart';

/// Small count boxes: Total, Present, Absent, Leave (and Not marked if given).
class SummaryChips extends StatelessWidget {
  const SummaryChips({
    super.key,
    required this.total,
    required this.present,
    required this.absent,
    required this.leave,
    this.notMarked,
  });

  final int total;
  final int present;
  final int absent;
  final int leave;
  final int? notMarked;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Chip(label: 'Total', value: total, color: AppColors.primary),
        _Chip(label: 'Present', value: present, color: attendanceColor(AttendanceStatus.present)),
        _Chip(label: 'Absent', value: absent, color: attendanceColor(AttendanceStatus.absent)),
        _Chip(label: 'Leave', value: leave, color: attendanceColor(AttendanceStatus.leave)),
        if (notMarked != null)
          _Chip(label: 'Not marked', value: notMarked!, color: AppColors.textMuted),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
