import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../domain/exam_models.dart';

class ExamRow extends StatelessWidget {
  const ExamRow({
    super.key,
    required this.exam,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Exam exam;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted);
    final date = exam.date;
    return HoverCard(
      onTap: onOpen,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.edit_note_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Text(
              exam.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamilyFallback: AppTheme.fontFallback,
                  ),
            ),
          ),
          Expanded(flex: 2, child: Text(exam.className, style: muted)),
          Expanded(
            flex: 2,
            child: Text(date == null ? '-' : AppDateUtils.toDisplay(date), style: muted),
          ),
          Expanded(
            flex: 3,
            child: Text(
              exam.studentsWithMarks == 0
                  ? 'No marks yet'
                  : '${exam.studentsWithMarks} students have marks',
              style: muted,
            ),
          ),
          IconButton(
            tooltip: 'Edit exam',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 20),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'Delete exam',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
