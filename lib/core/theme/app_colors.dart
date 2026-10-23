import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);
  static const accent = Color(0xFF14B8A6);
  static const gold = Color(0xFFF5B942);

  // Surfaces
  static const background = Color(0xFFF5F6FB);
  static const surface = Colors.white;
  static const sidebarTop = Color(0xFF1E1B4B);
  static const sidebarBottom = Color(0xFF12102E);
  static const border = Color(0xFFE6E8F2);

  // Text
  static const textDark = Color(0xFF1B1B3A);
  static const textMuted = Color(0xFF6B7194);

  // Status
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE11D48);
  static const info = Color(0xFF0EA5E9);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFDB2777)],
  );

  static const sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sidebarTop, sidebarBottom],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF1E1B4B).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
