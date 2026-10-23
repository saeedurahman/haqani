import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import 'daily_report_tab.dart';
import 'mark_attendance_tab.dart';
import 'monthly_report_tab.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Attendance',
                  subtitle: 'Mark the day, then check the reports',
                ),
                SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: AppColors.border,
                  labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Mark Attendance'),
                    Tab(text: 'Daily Report'),
                    Tab(text: 'Monthly Report'),
                  ],
                ),
                SizedBox(height: 24),
                Expanded(
                  child: TabBarView(
                    children: [
                      MarkAttendanceTab(),
                      DailyReportTab(),
                      MonthlyReportTab(),
                    ],
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
