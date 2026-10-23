import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.name, required this.gender, this.size = 48});

  final String name;
  final String gender;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = gender == 'female'
        ? const [Color(0xFFEC4899), Color(0xFFA855F7)]
        : const [Color(0xFF6366F1), Color(0xFF0EA5E9)];
    final letter = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          fontFamilyFallback: AppTheme.fontFallback,
        ),
      ),
    );
  }
}

class StudentStatusChip extends StatelessWidget {
  const StudentStatusChip({super.key, required this.isActive});

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
