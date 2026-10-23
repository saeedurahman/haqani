import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/report_kind.dart';
import 'report_page.dart';

const _icons = {
  ReportKind.students: Icons.groups_rounded,
  ReportKind.admissions: Icons.how_to_reg_rounded,
  ReportKind.attendance: Icons.event_available_rounded,
  ReportKind.fees: Icons.payments_rounded,
  ReportKind.defaulters: Icons.warning_amber_rounded,
  ReportKind.examResults: Icons.emoji_events_rounded,
  ReportKind.studentHistory: Icons.history_edu_rounded,
};

const _colors = {
  ReportKind.students: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  ReportKind.admissions: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
  ReportKind.attendance: [Color(0xFF14B8A6), Color(0xFF22C55E)],
  ReportKind.fees: [Color(0xFFF59E0B), Color(0xFFF97316)],
  ReportKind.defaulters: [Color(0xFFEF4444), Color(0xFFE11D48)],
  ReportKind.examResults: [Color(0xFFEC4899), Color(0xFFA855F7)],
  ReportKind.studentHistory: [Color(0xFF64748B), Color(0xFF334155)],
};

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: ListView(
              children: [
                const PageHeader(
                  title: 'Reports',
                  subtitle: 'Choose a report. You can print it or save it for Excel.',
                ),
                const SizedBox(height: 28),
                AdaptiveGrid(
                  maxColumns: 3,
                  minItemWidth: 330,
                  children: [
                    for (final (i, kind) in ReportKind.values.indexed)
                      FadeSlideIn(
                        delay: Duration(milliseconds: 50 * i),
                        child: _ReportTile(kind: kind),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.kind});

  final ReportKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = _colors[kind]!;
    return HoverCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ReportPage(kind: kind)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(_icons[kind], color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kind.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  kind.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
