import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_size.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/backup_models.dart';
import '../cubit/backup_state.dart';

/// Backups on this computer and on Google Drive, each with a Restore button.
class BackupListCard extends StatelessWidget {
  const BackupListCard({
    super.key,
    required this.state,
    required this.onRestore,
    required this.onLoadDrive,
  });

  final BackupState state;
  final ValueChanged<BackupFile> onRestore;
  final VoidCallback onLoadDrive;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings!;
    final showDrive = settings.driveConnected;
    return DefaultTabController(
      length: showDrive ? 2 : 1,
      child: SectionCard(
        title: 'Restore from a backup',
        icon: Icons.settings_backup_restore_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: AppColors.border,
              tabs: [
                const Tab(text: 'On this computer'),
                if (showDrive) const Tab(text: 'On Google Drive'),
              ],
            ),
            const SizedBox(height: 8),
            _TabBody(
              showDrive: showDrive,
              local: _List(
                files: state.localBackups,
                emptyText: 'No backups yet. Press Back Up Now.',
                enabled: !state.isBusy,
                onRestore: onRestore,
              ),
              drive: state.driveLoaded
                  ? _List(
                      files: state.driveBackups,
                      emptyText: 'No backups found in the Google Drive folder "School Backups".',
                      enabled: !state.isBusy,
                      onRestore: onRestore,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          label: 'Load backups from Google Drive',
                          icon: Icons.cloud_download_rounded,
                          style: AppButtonStyle.secondary,
                          isLoading: state.busy == BackupBusy.loadingDrive,
                          onPressed: state.isBusy ? null : onLoadDrive,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the tab that is selected, so the card grows with its content.
class _TabBody extends StatelessWidget {
  const _TabBody({required this.showDrive, required this.local, required this.drive});

  final bool showDrive;
  final Widget local;
  final Widget drive;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => showDrive && controller.index == 1 ? drive : local,
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.files,
    required this.emptyText,
    required this.enabled,
    required this.onRestore,
  });

  final List<BackupFile> files;
  final String emptyText;
  final bool enabled;
  final ValueChanged<BackupFile> onRestore;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(emptyText, style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Column(
      children: [
        for (final f in files)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    f.isOnDrive ? Icons.cloud_done_rounded : Icons.inventory_2_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(f.createdAt),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${f.name}  |  ${FileSize.format(f.size)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Restore',
                  icon: Icons.restore_rounded,
                  style: AppButtonStyle.secondary,
                  onPressed: enabled ? () => onRestore(f) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
