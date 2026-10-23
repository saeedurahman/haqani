import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/school_logo.dart';
import '../../../../core/widgets/section_card.dart';

/// Shows the logo and lets the user choose or remove it.
class LogoCard extends StatelessWidget {
  const LogoCard({
    super.key,
    required this.logoPath,
    required this.isSaving,
    required this.onChoose,
    required this.onRemove,
  });

  final String? logoPath;
  final bool isSaving;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'School logo',
      icon: Icons.image_rounded,
      child: Row(
        children: [
          SchoolLogo(path: logoPath, size: 96),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logoPath == null ? 'No logo yet.' : 'Your logo is set.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a PNG or JPG picture, under 5 MB. A square picture looks best.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: logoPath == null ? 'Choose Picture' : 'Change Picture',
                      icon: Icons.upload_rounded,
                      style: AppButtonStyle.secondary,
                      onPressed: isSaving ? null : onChoose,
                    ),
                    if (logoPath != null)
                      TextButton(onPressed: isSaving ? null : onRemove, child: const Text('Remove logo')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
