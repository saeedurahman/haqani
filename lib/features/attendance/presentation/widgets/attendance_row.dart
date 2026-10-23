import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../../students/presentation/widgets/student_avatar.dart';
import '../../domain/attendance_models.dart';
import 'status_toggle.dart';

class AttendanceRow extends StatelessWidget {
  const AttendanceRow({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.onWhatsApp,
  });

  final AttendanceEntry entry;
  final ValueChanged<String> onChanged;

  /// Opens WhatsApp to tell the parent about the absence.
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          StudentAvatar(name: entry.name, gender: entry.gender, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                Text('ID ${entry.admissionNo}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (entry.status == AttendanceStatus.absent) ...[
            WhatsAppIconButton(onPressed: onWhatsApp, tooltip: 'Tell the parent on WhatsApp'),
            const SizedBox(width: 12),
          ],
          StatusToggle(status: entry.status, onChanged: onChanged),
        ],
      ),
    );
  }
}
