import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/attendance_models.dart';

Color attendanceColor(String? status) => switch (status) {
      AttendanceStatus.present => AppColors.success,
      AttendanceStatus.absent => AppColors.danger,
      AttendanceStatus.leave => AppColors.warning,
      _ => AppColors.textMuted,
    };

IconData attendanceIcon(String status) => switch (status) {
      AttendanceStatus.present => Icons.check_circle_rounded,
      AttendanceStatus.absent => Icons.cancel_rounded,
      _ => Icons.beach_access_rounded,
    };
