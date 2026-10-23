import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.delete,
    this.isDangerous = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDangerous;

  /// Returns true only if the user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.delete,
    bool isDangerous = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDangerous: isDangerous,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final color = isDangerous ? AppColors.danger : AppColors.primary;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isDangerous
                      ? Icons.delete_outline_rounded
                      : Icons.help_outline_rounded,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: AppStrings.cancel,
                    style: AppButtonStyle.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  AppButton(
                    label: confirmLabel,
                    style: isDangerous
                        ? AppButtonStyle.danger
                        : AppButtonStyle.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
