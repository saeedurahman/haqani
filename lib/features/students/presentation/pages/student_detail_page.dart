import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../domain/student.dart';
import '../cubit/student_detail_cubit.dart';
import '../cubit/student_detail_state.dart';
import '../widgets/student_header.dart';
import '../widgets/student_history_tabs.dart';
import '../widgets/student_info_tab.dart';
import 'student_form_page.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentDetailCubit>()..load(studentId),
      child: _DetailView(studentId: studentId),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentDetailCubit, StudentDetailState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        final student = state.student;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Student'),
          ),
          body: switch (state.status) {
            StudentDetailStatus.initial || StudentDetailStatus.loading => const LoadingView(),
            StudentDetailStatus.failure => ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<StudentDetailCubit>().load(studentId),
              ),
            StudentDetailStatus.success => _Content(state: state, student: student!),
          },
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.student});

  final StudentDetailState state;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudentDetailCubit>();
    return DefaultTabController(
      length: 4,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            8,
            AppConstants.pagePadding,
            AppConstants.pagePadding,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudentHeader(
                    student: student,
                    onEdit: () async {
                      await Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => StudentFormPage(studentId: student.id),
                      ));
                      await cubit.load(student.id);
                    },
                    onToggleStatus: () => _toggle(context),
                  ),
                  const SizedBox(height: 24),
                  const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: AppColors.border,
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(text: 'Info'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Fees'),
                      Tab(text: 'Results'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _TabContent(state: state, student: student),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context) async {
    final cubit = context.read<StudentDetailCubit>();
    if (!student.isActive) {
      await cubit.reactivate();
      return;
    }
    final ok = await ConfirmDialog.show(
      context,
      title: 'Mark ${student.name} as left?',
      message: 'The student will be hidden from the main list. All records are kept.',
      confirmLabel: 'Mark as Left',
    );
    if (ok) await cubit.markAsLeft();
  }
}

/// Shows the selected tab. Plain switch so the page scrolls as one piece.
class _TabContent extends StatelessWidget {
  const _TabContent({required this.state, required this.student});

  final StudentDetailState state;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (controller.index) {
        0 => StudentInfoTab(student: student, documents: state.documents),
        1 => AttendanceTab(history: state.history),
        2 => FeesTab(history: state.history),
        _ => ResultsTab(history: state.history),
      },
    );
  }
}
