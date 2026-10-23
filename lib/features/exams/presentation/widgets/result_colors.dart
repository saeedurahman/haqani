import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/result_calculator.dart';

Color gradeColor(String grade) => switch (grade) {
      'A+' || 'A' => AppColors.success,
      'B' || 'C' => AppColors.primary,
      'D' || 'E' => AppColors.warning,
      'F' => AppColors.danger,
      _ => AppColors.textMuted,
    };

Color statusColor(ResultStatus status) => switch (status) {
      ResultStatus.pass => AppColors.success,
      ResultStatus.fail => AppColors.danger,
      ResultStatus.incomplete => AppColors.warning,
      ResultStatus.notEntered => AppColors.textMuted,
    };
