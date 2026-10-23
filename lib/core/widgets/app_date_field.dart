import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_date_utils.dart';

/// Read-only field that opens a date picker. Shows a clear (x) button when set.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.clearable = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Shows an (x) button to empty the date.
  final bool clearable;

  @override
  Widget build(BuildContext context) {
    final current = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _pick(context),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textMuted),
              suffixIcon: current == null || !clearable
                  ? null
                  : IconButton(
                      tooltip: 'Clear date',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => onChanged(null),
                    ),
            ),
            child: Text(
              current == null ? 'Select date' : AppDateUtils.toDisplay(current),
              style: TextStyle(
                fontSize: 15,
                color: current == null ? AppColors.textMuted : AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(1990),
      lastDate: lastDate ?? DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) onChanged(picked);
  }
}
