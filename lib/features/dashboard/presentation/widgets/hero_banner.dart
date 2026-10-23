import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/dashboard_summary.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.summary,
    required this.now,
    required this.onBackup,
  });

  final DashboardSummary summary;
  final DateTime now;

  /// Opens the Backup page.
  final VoidCallback onBackup;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(right: -60, top: -80, child: _Orb(size: 260, alpha: 0.12)),
          const Positioned(right: 140, bottom: -90, child: _Orb(size: 200, alpha: 0.09)),
          Padding(
            padding: const EdgeInsets.all(36),
            child: Row(
              children: [
                Expanded(child: _Welcome(summary: summary, now: now)),
                const SizedBox(width: 24),
                _BackupChip(lastBackup: summary.lastBackup, now: now, onTap: onBackup),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.summary, required this.now});

  final DashboardSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppDateUtils.toDisplay(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${AppDateUtils.greeting(now)}!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Welcome to ${summary.schoolName}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BackupChip extends StatelessWidget {
  const _BackupChip({required this.lastBackup, required this.now, required this.onTap});

  final DateTime? lastBackup;
  final DateTime now;
  final VoidCallback onTap;

  /// A backup older than this many days is shown as a warning.
  static const _staleDays = 7;

  @override
  Widget build(BuildContext context) {
    final last = lastBackup;
    final stale = last == null || now.difference(last).inDays >= _staleDays;
    final String title;
    final String detail;
    if (last == null) {
      title = 'No backup yet';
      detail = 'Tap to back up now';
    } else {
      title = AppDateUtils.toDisplay(last);
      detail = stale ? 'Backup is old. Tap to back up' : 'Last backup';
    }
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: stale ? AppColors.gold.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.25),
              width: stale ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                stale ? Icons.warning_amber_rounded : Icons.verified_rounded,
                color: AppColors.gold,
                size: 30,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    detail,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}
