import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final isPrimary = style == AppButtonStyle.primary;
    final color = style == AppButtonStyle.danger ? AppColors.danger : AppColors.primary;
    final foreground = style == AppButtonStyle.secondary ? color : Colors.white;

    return Opacity(
      opacity: enabled || isLoading ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF7C3AED)],
                  )
                : null,
            color: isPrimary
                ? null
                : style == AppButtonStyle.danger
                    ? AppColors.danger
                    : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: foreground,
                      ),
                    )
                  else if (icon != null)
                    Icon(icon, size: 20, color: foreground),
                  if (isLoading || icon != null) const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
