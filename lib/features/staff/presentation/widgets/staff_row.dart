import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../../students/presentation/widgets/student_avatar.dart';
import '../../domain/staff_member.dart';

class StaffRow extends StatelessWidget {
  const StaffRow({super.key, required this.member, required this.onTap});

  final StaffMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted);
    final joined = member.joiningDate;
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          StudentAvatar(name: member.name, gender: 'male', size: 48),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                const SizedBox(height: 2),
                Text(member.designation.isEmpty ? 'No designation' : member.designation, style: muted),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text(member.phone.isEmpty ? '-' : member.phone, style: muted)),
          Expanded(
            flex: 3,
            child: Text(joined == null ? '-' : 'Joined ${AppDateUtils.toDisplay(joined)}', style: muted),
          ),
          Expanded(flex: 2, child: Text(MoneyUtils.format(member.salary), style: muted)),
          _StatusChip(isActive: member.isActive),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isActive ? 'Active' : 'Left',
        style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
