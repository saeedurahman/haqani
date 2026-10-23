import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/backup_models.dart';
import '../cubit/backup_state.dart';

/// Where backups are saved on this computer.
class BackupFolderCard extends StatelessWidget {
  const BackupFolderCard({
    super.key,
    required this.settings,
    required this.onChoose,
    required this.onUseDefault,
  });

  final BackupSettings settings;
  final VoidCallback onChoose;
  final VoidCallback onUseDefault;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Backup folder',
      icon: Icons.folder_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.isDefaultFolder ? 'App folder (default)' : 'Chosen folder',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          SelectableText(settings.folder, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            'The newest 10 backups are kept here. Tip: choose a folder on a USB drive.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Change Folder',
                icon: Icons.drive_file_move_rounded,
                style: AppButtonStyle.secondary,
                onPressed: onChoose,
              ),
              if (!settings.isDefaultFolder)
                TextButton(onPressed: onUseDefault, child: const Text('Use the app folder')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Connect or disconnect Google Drive.
class DriveCard extends StatelessWidget {
  const DriveCard({
    super.key,
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
  });

  final BackupState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings!;
    return SectionCard(
      title: 'Google Drive',
      icon: Icons.cloud_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!settings.driveConfigured)
            const _Note(
              icon: Icons.info_rounded,
              color: AppColors.warning,
              text: 'Google Drive is not set up on this computer. Ask the person who installed '
                  'the app to add the Google client ID (see README). Backups on this computer still work.',
            )
          else if (settings.driveConnected) ...[
            const _Note(
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              text: 'Connected. Every backup is also uploaded to the folder "School Backups".',
            ),
            const SizedBox(height: 10),
            Text(settings.driveEmail!, style: Theme.of(context).textTheme.titleMedium),
          ] else
            Text(
              'Connect your Google account once. Backups are then also saved in your Google Drive, '
              'in a folder called "School Backups". Needs internet only for the upload.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 18),
          if (settings.driveConfigured)
            settings.driveConnected
                ? AppButton(
                    label: 'Disconnect',
                    icon: Icons.link_off_rounded,
                    style: AppButtonStyle.secondary,
                    onPressed: onDisconnect,
                  )
                : AppButton(
                    label: 'Connect Google Drive',
                    icon: Icons.link_rounded,
                    isLoading: state.busy == BackupBusy.connecting,
                    onPressed: state.isBusy ? null : onConnect,
                  ),
          if (state.busy == BackupBusy.connecting)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Your browser opened. Sign in with Google and press Allow, then come back here.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
