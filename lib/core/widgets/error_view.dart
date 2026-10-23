import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import 'app_button.dart';
import 'empty_state.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: AppStrings.somethingWentWrong,
      message: message,
      action: onRetry == null
          ? null
          : AppButton(
              label: AppStrings.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
    );
  }
}
