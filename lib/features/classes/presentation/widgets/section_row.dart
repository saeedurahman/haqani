import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/school_class.dart';

class SectionRow extends StatelessWidget {
  const SectionRow({
    super.key,
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  final SchoolSection section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final teacher = section.classTeacherName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              section.name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Text(
              'Section ${section.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: teacher == null
                      ? AppColors.textMuted
                      : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    teacher ?? 'No class teacher',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: teacher == null
                          ? AppColors.textMuted
                          : AppColors.textDark,
                      fontStyle: teacher == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${section.studentCount} students',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          IconButton(
            tooltip: 'Edit section',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 20),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'Delete section',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
