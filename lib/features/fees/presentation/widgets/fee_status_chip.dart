import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/fee_models.dart';

Color feeStatusColor(String status) => switch (status) {
      FeeStatus.paid => AppColors.success,
      FeeStatus.partial => AppColors.warning,
      _ => AppColors.danger,
    };

class FeeStatusChip extends StatelessWidget {
  const FeeStatusChip({super.key, required this.voucher});

  final FeeVoucher voucher;

  @override
  Widget build(BuildContext context) {
    if (voucher.carriedForward) {
      return const StatusChip(label: 'Carried forward', color: AppColors.textMuted);
    }
    return StatusChip(
      label: FeeStatus.label(voucher.status),
      color: feeStatusColor(voucher.status),
    );
  }
}
