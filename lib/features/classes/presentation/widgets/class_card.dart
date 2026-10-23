import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/school_class.dart';
import 'section_row.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.schoolClass,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSection,
    required this.onEditSection,
    required this.onDeleteSection,
  });

  final SchoolClass schoolClass;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSection;
  final ValueChanged<SchoolSection> onEditSection;
  final ValueChanged<SchoolSection> onDeleteSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            schoolClass: schoolClass,
            canMoveUp: canMoveUp,
            canMoveDown: canMoveDown,
            onMoveUp: onMoveUp,
            onMoveDown: onMoveDown,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: 18),
          if (schoolClass.sections.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'No sections yet.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            for (final section in schoolClass.sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionRow(
                  section: section,
                  onEdit: () => onEditSection(section),
                  onDelete: () => onDeleteSection(section),
                ),
              ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddSection,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Section'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.schoolClass,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onDelete,
  });

  final SchoolClass schoolClass;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.class_rounded, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schoolClass.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                schoolClass.sections.length == 1
                    ? '1 section'
                    : '${schoolClass.sections.length} sections',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '${schoolClass.studentCount} students',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Move up',
          onPressed: canMoveUp ? onMoveUp : null,
          icon: const Icon(Icons.arrow_upward_rounded),
        ),
        IconButton(
          tooltip: 'Move down',
          onPressed: canMoveDown ? onMoveDown : null,
          icon: const Icon(Icons.arrow_downward_rounded),
        ),
        IconButton(
          tooltip: 'Edit class',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
          color: AppColors.primary,
        ),
        IconButton(
          tooltip: 'Delete class',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.danger,
        ),
      ],
    );
  }
}
