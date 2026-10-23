import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: value.isEmpty ? AppColors.textMuted : AppColors.textDark,
                fontFamilyFallback: AppTheme.fontFallback,
              ),
        ),
      ],
    );
  }
}
