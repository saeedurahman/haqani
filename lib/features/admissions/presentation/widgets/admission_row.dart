import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../students/domain/student.dart';
import '../../../students/presentation/widgets/student_avatar.dart';

class AdmissionRow extends StatelessWidget {
  const AdmissionRow({super.key, required this.student, required this.onCertificate});

  final Student student;
  final VoidCallback onCertificate;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted);
    final date = student.admissionDate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
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
          Expanded(flex: 2, child: Text('No. ${student.admissionNo}', style: muted)),
          Expanded(
            flex: 3,
            child: Text(date == null ? '-' : AppDateUtils.toDisplay(date), style: muted),
          ),
          Expanded(flex: 3, child: Text(student.classLabel, style: muted)),
          AppButton(
            label: 'Leaving Certificate',
            icon: Icons.workspace_premium_rounded,
            style: AppButtonStyle.secondary,
            onPressed: onCertificate,
          ),
        ],
      ),
    );
  }
}
