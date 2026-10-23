import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/fee_models.dart';
import 'fee_status_chip.dart';
import 'receipt_links.dart';

class VoucherRow extends StatelessWidget {
  const VoucherRow({
    super.key,
    required this.voucher,
    required this.onReceipt,
    required this.onRemind,
  });

  final FeeVoucher voucher;
  /// Called with the receipt number to show.
  final ValueChanged<String> onReceipt;

  /// Opens WhatsApp with a fee reminder. Only shown while a balance is left.
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.student.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                Text(
                  'ID ${voucher.student.admissionNo}  |  ${voucher.student.classLabel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _Amount(label: 'Total', value: voucher.total, style: muted),
          _Amount(label: 'Paid', value: voucher.paidAmount, style: muted, color: AppColors.success),
          _Amount(
            label: 'Balance',
            value: voucher.balance,
            style: muted,
            color: voucher.balance > 0 ? AppColors.danger : AppColors.textMuted,
          ),
          SizedBox(
            width: 130,
            child: Align(alignment: Alignment.centerRight, child: FeeStatusChip(voucher: voucher)),
          ),
          SizedBox(
            width: 48,
            child: voucher.balance > 0
                ? WhatsAppIconButton(onPressed: onRemind, tooltip: 'Send fee reminder on WhatsApp')
                : null,
          ),
          SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.centerRight,
              child: ReceiptLinks(payments: voucher.payments, onOpen: onReceipt),
            ),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value, required this.style, this.color});

  final String label;
  final int value;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            MoneyUtils.format(value),
            style: style?.copyWith(fontWeight: FontWeight.w700, color: color ?? AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

/// Billed / Collected / Pending boxes above the voucher list.
class VoucherTotals extends StatelessWidget {
  const VoucherTotals({
    super.key,
    required this.billed,
    required this.collected,
    required this.pending,
  });

  final int billed;
  final int collected;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _Box(label: 'Billed', value: billed, color: AppColors.primary),
        _Box(label: 'Collected', value: collected, color: AppColors.success),
        _Box(label: 'Pending', value: pending, color: pending > 0 ? AppColors.danger : AppColors.textMuted),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            MoneyUtils.format(value),
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
