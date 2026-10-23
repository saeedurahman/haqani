import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The school logo, or the default book icon when there is no logo.
class SchoolLogo extends StatelessWidget {
  const SchoolLogo({super.key, required this.path, this.size = 48});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.3);
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gold, Color(0xFFF97316)],
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.auto_stories_rounded, color: Colors.white, size: size * 0.54),
    );
    final logo = path;
    if (logo == null) return fallback;
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        padding: EdgeInsets.all(size * 0.06),
        child: Image.file(
          File(logo),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}
