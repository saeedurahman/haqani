import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../cubit/students_cubit.dart';
import '../cubit/students_state.dart';
import '../widgets/student_row.dart';
import '../widgets/students_filter_bar.dart';
import 'student_detail_page.dart';
import 'student_form_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentsCubit>()..load(),
      child: const _StudentsView(),
    );
  }
}

class _StudentsView extends StatelessWidget {
  const _StudentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Students',
                  subtitle: 'Find, add and manage students',
                  trailing: AppButton(
                    label: 'Add Student',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => _open(context, const StudentFormPage()),
                  ),
                ),
                const SizedBox(height: 24),
                const StudentsFilterBar(),
                const SizedBox(height: 24),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a page, then refreshes the list when it comes back.
Future<void> _open(BuildContext context, Widget page) async {
  final cubit = context.read<StudentsCubit>();
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  await cubit.refresh();
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsCubit, StudentsState>(
      builder: (context, state) {
        switch (state.status) {
          case StudentsStatus.initial:
          case StudentsStatus.loading:
            return const LoadingView();
          case StudentsStatus.failure:
            return ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<StudentsCubit>().load(),
            );
          case StudentsStatus.success:
            if (state.students.isEmpty) return _Empty(state: state);
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: state.students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final student = state.students[i];
                return StudentRow(
                  student: student,
                  onTap: () => _open(context, StudentDetailPage(studentId: student.id)),
                );
              },
            );
        }
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.state});

  final StudentsState state;

  @override
  Widget build(BuildContext context) {
    if (state.hasFilter) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No students found',
        message: 'Try a different name, ID or class.',
      );
    }
    return EmptyState(
      icon: Icons.school_rounded,
      title: 'No students yet',
      message: 'Add your first student to get started.',
      action: AppButton(
        label: 'Add Student',
        icon: Icons.person_add_alt_1_rounded,
        onPressed: () => _open(context, const StudentFormPage()),
      ),
    );
  }
}
