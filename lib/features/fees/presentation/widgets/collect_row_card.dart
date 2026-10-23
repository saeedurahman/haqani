import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../students/presentation/widgets/student_avatar.dart';
import '../cubit/collect_fee_state.dart';
import 'money_field.dart';

/// One student (or brother / sister) on the Collect Fee screen.
class CollectRowCard extends StatelessWidget {
  const CollectRowCard({
    super.key,
    required this.row,
    required this.showCheckbox,
    required this.onInclude,
    required this.onPay,
    required this.onMisc,
    required this.onDiscount,
    required this.onCreateVoucher,
  });

  final CollectRow row;
  final bool showCheckbox;
  final ValueChanged<bool> onInclude;
  final ValueChanged<int> onPay;
  final ValueChanged<int> onMisc;
  final ValueChanged<int> onDiscount;
  final VoidCallback onCreateVoucher;

  @override
  Widget build(BuildContext context) {
    final voucher = row.voucher;
    final active = row.include && row.canPay;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showCheckbox && row.canPay)
                Checkbox(value: row.include, onChanged: (v) => onInclude(v ?? false))
              else if (showCheckbox)
                const SizedBox(width: 48),
              StudentAvatar(name: row.student.name, gender: row.student.gender, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamilyFallback: AppTheme.fontFallback,
                          ),
                    ),
                    Text(
                      'ID ${row.student.admissionNo}  |  ${row.student.classLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (voucher != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Balance', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      MoneyUtils.format(row.balance),
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (voucher == null)
            _NoDue(onCreate: onCreateVoucher)
          else ...[
            Text(
              'Fee for ${voucher.forMonth}:  monthly ${MoneyUtils.format(voucher.monthlyFee)}'
              '${voucher.annualFee > 0 ? ', annual ${MoneyUtils.format(voucher.annualFee)}' : ''}'
              '${voucher.admissionFee > 0 ? ', admission ${MoneyUtils.format(voucher.admissionFee)}' : ''}'
              '${voucher.previousDues > 0 ? ', previous dues ${MoneyUtils.format(voucher.previousDues)}' : ''}'
              '${voucher.paidAmount > 0 ? '  (paid ${MoneyUtils.format(voucher.paidAmount)})' : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                MoneyField(label: 'Misc fee', value: row.miscFee, onChanged: onMisc),
                MoneyField(label: 'Discount', value: row.discount, onChanged: onDiscount),
                MoneyField(
                  label: 'Receive now',
                  value: row.pay,
                  width: 170,
                  enabled: row.include,
                  onChanged: onPay,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NoDue extends StatelessWidget {
  const _NoDue({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success),
        const SizedBox(width: 10),
        const Expanded(child: Text('Nothing is due.')),
        AppButton(
          label: "Create this month's voucher",
          icon: Icons.add_rounded,
          style: AppButtonStyle.secondary,
          onPressed: onCreate,
        ),
      ],
    );
  }
}
