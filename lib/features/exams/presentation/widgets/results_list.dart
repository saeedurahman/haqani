import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/result_calculator.dart';
import 'result_colors.dart';

/// Students ordered by position. Tap one to open the result card.
class ResultsList extends StatelessWidget {
  const ResultsList({super.key, required this.results, required this.onOpen});

  final List<StudentResult> results;
  final ValueChanged<StudentResult> onOpen;

  @override
  Widget build(BuildContext context) {
    if (results.every((r) => r.status == ResultStatus.notEntered)) {
      return const EmptyState(
        icon: Icons.assignment_turned_in_rounded,
        title: 'No marks yet',
        message: 'Enter marks first. Results, grades and positions show here.',
      );
    }
    final sorted = [...results]..sort((a, b) {
        if (a.position != null && b.position != null) {
          final byPosition = a.position!.compareTo(b.position!);
          if (byPosition != 0) return byPosition;
        } else if (a.position != null) {
          return -1;
        } else if (b.position != null) {
          return 1;
        }
        return a.student.name.compareTo(b.student.name);
      });
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _Row(result: sorted[i], onTap: () => onOpen(sorted[i])),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.result, required this.onTap});

  final StudentResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final noMarks = result.status == ResultStatus.notEntered;
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted);
    return HoverCard(
      onTap: noMarks ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _PositionBadge(position: result.position),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.student.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                Text('ID ${result.student.admissionNo}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(noMarks ? '-' : '${result.obtained} / ${result.maxMarks}', style: muted),
          ),
          Expanded(
            flex: 2,
            child: Text(noMarks ? '-' : '${result.percent.toStringAsFixed(1)}%', style: muted),
          ),
          SizedBox(
            width: 70,
            child: Center(child: StatusChip(label: result.grade, color: gradeColor(result.grade))),
          ),
          SizedBox(
            width: 110,
            child: Center(
              child: StatusChip(label: result.status.label, color: statusColor(result.status)),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: noMarks ? Colors.transparent : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position});

  final int? position;

  @override
  Widget build(BuildContext context) {
    final top = position != null && position! <= 3;
    final color = switch (position) {
      1 => AppColors.gold,
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: top ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        position == null ? '-' : '$position',
        style: TextStyle(
          color: top ? Colors.white : color,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
