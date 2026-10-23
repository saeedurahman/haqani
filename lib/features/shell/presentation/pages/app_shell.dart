import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../admissions/presentation/pages/admissions_flow.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../classes/presentation/pages/classes_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../students/presentation/pages/students_flow.dart';
import '../cubit/app_section.dart';
import '../cubit/navigation_cubit.dart';
import '../widgets/app_sidebar.dart';
import 'coming_soon_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(state.section),
                    child: _pageFor(state.section),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageFor(AppSection section) {
    switch (section) {
      case AppSection.dashboard:
        return const DashboardPage();
      case AppSection.attendance:
        return const AttendancePage();
      case AppSection.admissions:
        return const AdmissionsFlow();
      case AppSection.students:
        return const StudentsFlow();
      case AppSection.classes:
        return const ClassesPage();
      default:
        return ComingSoonPage(section: section);
    }
  }
}
