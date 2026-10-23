import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

/// Previous / next buttons around the month name.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.onMove,
    this.canGoNext = true,
  });

  /// Any day of the month to show.
  final DateTime month;
  final ValueChanged<int> onMove;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Previous month',
          onPressed: () => onMove(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(
          width: 170,
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textDark),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Next month',
          onPressed: canGoNext ? () => onMove(1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
