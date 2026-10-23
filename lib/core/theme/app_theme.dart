import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Inter';

  /// Urdu text falls back to Noto Naskh Arabic, so Urdu names show well.
  static const fontFallback = ['NotoNaskhArabic'];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.6),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          AppColors.textMuted.withValues(alpha: 0.35),
        ),
        radius: const Radius.circular(8),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    TextStyle style(TextStyle? s, double size, FontWeight weight, {Color? color}) {
      return (s ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textDark,
        fontFamilyFallback: fontFallback,
        letterSpacing: size >= 24 ? -0.4 : 0,
      );
    }

    return base.copyWith(
      displaySmall: style(base.displaySmall, 34, FontWeight.w800),
      headlineMedium: style(base.headlineMedium, 28, FontWeight.w800),
      headlineSmall: style(base.headlineSmall, 22, FontWeight.w700),
      titleLarge: style(base.titleLarge, 18, FontWeight.w700),
      titleMedium: style(base.titleMedium, 16, FontWeight.w600),
      bodyLarge: style(base.bodyLarge, 16, FontWeight.w400),
      bodyMedium: style(base.bodyMedium, 14, FontWeight.w400),
      bodySmall: style(base.bodySmall, 12.5, FontWeight.w400,
          color: AppColors.textMuted),
      labelLarge: style(base.labelLarge, 15, FontWeight.w600),
    );
  }
}
