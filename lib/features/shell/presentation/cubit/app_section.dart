import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

enum AppSection {
  dashboard(AppStrings.dashboard, Icons.space_dashboard_rounded),
  students(AppStrings.students, Icons.school_rounded),
  admissions(AppStrings.admissions, Icons.how_to_reg_rounded),
  attendance(AppStrings.attendance, Icons.event_available_rounded),
  classes(AppStrings.classes, Icons.class_rounded),
  fees(AppStrings.fees, Icons.payments_rounded),
  staff(AppStrings.staff, Icons.badge_rounded),
  exams(AppStrings.exams, Icons.edit_note_rounded),
  reports(AppStrings.reports, Icons.bar_chart_rounded),
  backup(AppStrings.backup, Icons.cloud_sync_rounded),
  settings(AppStrings.settings, Icons.settings_rounded);

  const AppSection(this.label, this.icon);

  final String label;
  final IconData icon;
}
