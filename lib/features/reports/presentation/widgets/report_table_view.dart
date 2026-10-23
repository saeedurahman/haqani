import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/report_models.dart';

/// Numbers shown above the tables.
class ReportStats extends StatelessWidget {
  const ReportStats({super.key, required this.stats});

  final List<ReportStat> stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final s in stats)
          Container(
            constraints: const BoxConstraints(minWidth: 170),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  s.value,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A report table as slivers, so long lists scroll smoothly.
List<Widget> reportTableSlivers(BuildContext context, ReportTable table) {
  final text = Theme.of(context).textTheme;
  Widget cell(String value, ReportColumn c, {bool header = false, bool bold = false}) {
    return Expanded(
      flex: c.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: c.type.alignsRight ? TextAlign.right : TextAlign.left,
          style: (header ? text.bodySmall : text.bodyMedium)?.copyWith(
            fontWeight: header || bold ? FontWeight.w700 : FontWeight.w400,
            color: header ? AppColors.textMuted : AppColors.textDark,
            fontFamilyFallback: AppTheme.fontFallback,
          ),
        ),
      ),
    );
  }

  final lastIndex = table.rows.length - 1;
  return [
    if (table.heading != null)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Text(table.heading!, style: text.titleLarge),
        ),
      ),
    SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(children: [for (final c in table.columns) cell(c.label, c, header: true)]),
      ),
    ),
    if (table.rows.isEmpty)
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: _boxDecoration(bottom: true),
          child: Text('No records.', style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
        ),
      )
    else
      SliverList.builder(
        itemCount: table.rows.length,
        itemBuilder: (context, r) {
          final isTotal = table.boldLastRow && r == lastIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: _boxDecoration(
              bottom: r == lastIndex,
              color: isTotal
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : (r.isOdd ? AppColors.background : AppColors.surface),
            ),
            child: Row(
              children: [
                for (var i = 0; i < table.columns.length; i++)
                  cell(table.rows[r][i], table.columns[i], bold: isTotal),
              ],
            ),
          );
        },
      ),
    const SliverToBoxAdapter(child: SizedBox(height: 20)),
  ];
}

BoxDecoration _boxDecoration({bool bottom = false, Color color = AppColors.surface}) {
  return BoxDecoration(
    color: color,
    border: const Border(
      left: BorderSide(color: AppColors.border),
      right: BorderSide(color: AppColors.border),
      bottom: BorderSide(color: AppColors.border),
    ),
    borderRadius: bottom ? const BorderRadius.vertical(bottom: Radius.circular(14)) : null,
  );
}
