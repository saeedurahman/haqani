import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../students/domain/student_extras.dart';

/// Class dropdown, plus a Section dropdown when the class has sections.
class ClassSectionPicker extends StatelessWidget {
  const ClassSectionPicker({
    super.key,
    required this.classes,
    required this.classId,
    required this.sectionId,
    required this.onClassChanged,
    required this.onSectionChanged,
  });

  final List<ClassOption> classes;
  final int? classId;
  final int? sectionId;
  final ValueChanged<int?> onClassChanged;
  final ValueChanged<int?> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final selected = classes.where((c) => c.id == classId).firstOrNull;
    final sections = selected?.sections ?? const <SectionOption>[];
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _Labeled(
          label: 'Class',
          width: 240,
          child: DropdownButtonFormField<int>(
            key: ValueKey('class-$classId'),
            initialValue: classId,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.class_rounded, size: 20, color: AppColors.textMuted),
            ),
            items: [
              for (final c in classes) DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: onClassChanged,
          ),
        ),
        if (sections.isNotEmpty)
          _Labeled(
            label: 'Section',
            width: 200,
            child: DropdownButtonFormField<int?>(
              key: ValueKey('section-$classId-$sectionId'),
              initialValue: sectionId,
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('All sections')),
                for (final s in sections)
                  DropdownMenuItem<int?>(value: s.id, child: Text('Section ${s.name}')),
              ],
              onChanged: onSectionChanged,
            ),
          ),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.width, required this.child});

  final String label;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
