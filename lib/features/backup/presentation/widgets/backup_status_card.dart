import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/backup_state.dart';

/// Big card: when was the last backup, and the Back Up Now button.
class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({super.key, required this.state, required this.onBackup});

  final BackupState state;
  final VoidCallback onBackup;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings!;
    final last = settings.lastBackup;
    final backedUp = last != null;
    final today = last != null && DateUtils.isSameDay(last, DateTime.now());
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              backedUp ? Icons.verified_rounded : Icons.cloud_off_rounded,
              color: backedUp ? AppColors.gold : Colors.white70,
              size: 40,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backedUp ? (today ? 'Your data is backed up today' : 'Last backup') : 'No backup yet',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  backedUp
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(last)
                      : 'Press Back Up Now to save a copy of all school data.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 15),
                ),
                if (settings.drivePending) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Waiting to upload to Google Drive (no internet earlier).',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          _WhiteButton(
            busy: state.busy == BackupBusy.backingUp,
            enabled: !state.isBusy,
            onPressed: onBackup,
          ),
        ],
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({required this.busy, required this.enabled, required this.onPressed});

  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || busy ? 1 : 0.6,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  )
                else
                  const Icon(Icons.backup_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  busy ? 'Backing up...' : 'Back Up Now',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

