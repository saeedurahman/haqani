import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../domain/student.dart';
import 'student_avatar.dart';

class StudentRow extends StatelessWidget {
  const StudentRow({super.key, required this.student, required this.onTap});

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted);
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          StudentAvatar(name: student.name, gender: student.gender),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.fatherName.isEmpty ? 'Father: -' : 'Father: ${student.fatherName}',
                  overflow: TextOverflow.ellipsis,
                  style: muted?.copyWith(fontFamilyFallback: AppTheme.fontFallback),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('ID ${student.admissionNo}', style: muted)),
          Expanded(flex: 3, child: Text(student.classLabel, style: muted)),
          Expanded(
            flex: 3,
            child: Text(student.phone.isEmpty ? '-' : student.phone, style: muted),
          ),
          StudentStatusChip(isActive: student.isActive),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
