import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../shell/presentation/cubit/app_section.dart';
import '../../../shell/presentation/cubit/navigation_cubit.dart';
import '../../domain/dashboard_summary.dart';
import 'hero_banner.dart';
import 'quick_action_tile.dart';
import 'section_title.dart';
import 'stat_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.summary, required this.now});

  final DashboardSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          child: HeroBanner(
            summary: summary,
            now: now,
            onBackup: () => nav.select(AppSection.backup),
          ),
        ),
        const SizedBox(height: 36),
        const FadeSlideIn(
          delay: Duration(milliseconds: 80),
          child: SectionTitle('What do you want to do?'),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: AdaptiveGrid(
            minItemWidth: 250,
            children: [
              QuickActionTile(
                label: AppStrings.addStudent,
                icon: Icons.person_add_alt_1_rounded,
                colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                onTap: () => nav.select(AppSection.admissions),
              ),
              QuickActionTile(
                label: AppStrings.markAttendance,
                icon: Icons.fact_check_rounded,
                colors: const [Color(0xFF14B8A6), Color(0xFF22C55E)],
                onTap: () => nav.select(AppSection.attendance),
              ),
              QuickActionTile(
                label: AppStrings.collectFee,
                icon: Icons.account_balance_wallet_rounded,
                colors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
                onTap: () => nav.select(AppSection.fees),
              ),
              QuickActionTile(
                label: AppStrings.reports,
                icon: Icons.insights_rounded,
                colors: const [Color(0xFFEC4899), Color(0xFFE11D48)],
                onTap: () => nav.select(AppSection.reports),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const FadeSlideIn(
          delay: Duration(milliseconds: 200),
          child: SectionTitle('School at a glance'),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: AdaptiveGrid(
            maxColumns: 3,
            minItemWidth: 250,
            children: [
              StatCard(
                label: 'Students',
                value: '${summary.totalStudents}',
                icon: Icons.school_rounded,
                color: AppColors.primary,
                onTap: () => nav.select(AppSection.students),
              ),
              StatCard(
                label: 'Present today',
                value: '${summary.presentToday}',
                icon: Icons.how_to_reg_rounded,
                color: AppColors.success,
                onTap: () => nav.select(AppSection.attendance),
              ),
              StatCard(
                label: 'Absent today',
                value: '${summary.absentToday}',
                icon: Icons.person_off_rounded,
                color: AppColors.danger,
                onTap: () => nav.select(AppSection.attendance),
              ),
              StatCard(
                label: 'Fees collected this month',
                value: MoneyUtils.format(summary.feesCollectedThisMonth),
                icon: Icons.payments_rounded,
                color: AppColors.warning,
                onTap: () => nav.select(AppSection.fees),
              ),
              StatCard(
                label: summary.defaulters == 1
                    ? 'Fee pending (1 student)'
                    : 'Fee pending (${summary.defaulters} students)',
                value: MoneyUtils.format(summary.pendingFees),
                icon: Icons.hourglass_bottom_rounded,
                color: summary.pendingFees > 0 ? AppColors.danger : AppColors.textMuted,
                onTap: () => nav.select(AppSection.reports),
              ),
              StatCard(
                label: 'Teachers & staff',
                value: '${summary.totalStaff}',
                icon: Icons.badge_rounded,
                color: AppColors.info,
                onTap: () => nav.select(AppSection.staff),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
