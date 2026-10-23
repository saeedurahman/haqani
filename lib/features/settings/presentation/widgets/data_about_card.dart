import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';

/// Where the data is kept, a link to Backup, and the app version.
class DataAboutCard extends StatelessWidget {
  const DataAboutCard({
    super.key,
    required this.dataFolder,
    required this.onOpenFolder,
    required this.onOpenBackup,
  });

  final String dataFolder;
  final VoidCallback onOpenFolder;
  final VoidCallback onOpenBackup;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SectionCard(
      title: 'Data and backup',
      icon: Icons.storage_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All school data is saved on this computer in:', style: text.bodySmall),
          const SizedBox(height: 4),
          SelectableText(dataFolder, style: text.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Open Folder',
                icon: Icons.folder_open_rounded,
                style: AppButtonStyle.secondary,
                onPressed: onOpenFolder,
              ),
              AppButton(
                label: 'Go to Backup',
                icon: Icons.cloud_sync_rounded,
                style: AppButtonStyle.secondary,
                onPressed: onOpenBackup,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 14),
          Text(
            '${AppStrings.appName} School Management  |  Version ${AppConstants.appVersion}',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text('Works fully offline. No login is needed.', style: text.bodySmall),
        ],
      ),
    );
  }
}
