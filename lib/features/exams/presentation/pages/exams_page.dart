import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import 'exams_tab.dart';
import 'subjects_tab.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(title: 'Exams', subtitle: 'Create exams, enter marks and print result cards'),
                  SizedBox(height: 16),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: AppColors.border,
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    tabs: [Tab(text: 'Exams'), Tab(text: 'Subjects')],
                  ),
                  SizedBox(height: 24),
                  Expanded(child: TabBarView(children: [ExamsTab(), SubjectsTab()])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
