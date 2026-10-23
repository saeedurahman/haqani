import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../cubit/app_section.dart';

/// Shown for sections whose module has not been built yet.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: section.label),
          Expanded(
            child: EmptyState(
              icon: section.icon,
              title: section.label,
              message: AppStrings.comingSoon,
            ),
          ),
        ],
      ),
    );
  }
}
