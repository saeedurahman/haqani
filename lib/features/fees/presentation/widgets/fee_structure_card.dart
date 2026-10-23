import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/fee_models.dart';
import 'money_field.dart';

/// Fees of one class with its own Save button.
class FeeStructureCard extends StatefulWidget {
  const FeeStructureCard({super.key, required this.fee, required this.onSave});

  final ClassFee fee;
  final void Function(int monthly, int annual, int admission) onSave;

  @override
  State<FeeStructureCard> createState() => _FeeStructureCardState();
}

class _FeeStructureCardState extends State<FeeStructureCard> {
  late int _monthly = widget.fee.monthlyFee;
  late int _annual = widget.fee.annualFee;
  late int _admission = widget.fee.admissionFee;

  bool get _changed =>
      _monthly != widget.fee.monthlyFee ||
      _annual != widget.fee.annualFee ||
      _admission != widget.fee.admissionFee;

  @override
  void didUpdateWidget(FeeStructureCard old) {
    super.didUpdateWidget(old);
    if (old.fee != widget.fee) {
      _monthly = widget.fee.monthlyFee;
      _annual = widget.fee.annualFee;
      _admission = widget.fee.admissionFee;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notSet = widget.fee.monthlyFee == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.class_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fee.className, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  notSet ? 'Fee not set yet' : 'Fee is set',
                  style: TextStyle(
                    color: notSet ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          MoneyField(label: 'Monthly fee', value: _monthly, onChanged: (v) => setState(() => _monthly = v)),
          const SizedBox(width: 12),
          MoneyField(label: 'Annual fee', value: _annual, onChanged: (v) => setState(() => _annual = v)),
          const SizedBox(width: 12),
          MoneyField(label: 'Admission fee', value: _admission, onChanged: (v) => setState(() => _admission = v)),
          const SizedBox(width: 16),
          AppButton(
            label: 'Save',
            icon: Icons.save_rounded,
            onPressed: _changed ? () => widget.onSave(_monthly, _annual, _admission) : null,
          ),
        ],
      ),
    );
  }
}
