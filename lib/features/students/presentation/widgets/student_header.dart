import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/student.dart';
import 'student_avatar.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onWhatsApp,
  });

  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          StudentAvatar(name: student.name, gender: student.gender, size: 84),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFamilyFallback: AppTheme.fontFallback,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (student.fatherName.isNotEmpty) 'Father: ${student.fatherName}',
                    'ID ${student.admissionNo}',
                    student.classLabel,
                  ].join('   |   '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontFamilyFallback: AppTheme.fontFallback,
                  ),
                ),
                if (!student.isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Left school',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderButton(label: 'Edit', icon: Icons.edit_rounded, onPressed: onEdit),
                const SizedBox(height: 10),
                _HeaderButton(label: 'WhatsApp', icon: Icons.chat_rounded, onPressed: onWhatsApp),
                const SizedBox(height: 10),
                _HeaderButton(
                  label: student.isActive ? 'Mark as Left' : 'Make Active',
                  icon: student.isActive ? Icons.logout_rounded : Icons.restart_alt_rounded,
                  onPressed: onToggleStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

