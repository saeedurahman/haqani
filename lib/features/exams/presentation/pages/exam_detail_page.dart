import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../cubit/marks_cubit.dart';
import '../cubit/marks_state.dart';
import '../widgets/marks_grid.dart';
import '../widgets/results_list.dart';
import 'result_card_page.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({super.key, required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MarksCubit>()..load(examId),
      child: _View(examId: examId),
    );
  }
}

class _View extends StatelessWidget {
  const _View({required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarksCubit, MarksState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        final sheet = state.sheet;
        final date = sheet?.exam.date;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              sheet == null
                  ? 'Exam'
                  : '${sheet.exam.name}  |  ${sheet.exam.className}'
                      '${date == null ? '' : '  |  ${AppDateUtils.toDisplay(date)}'}',
            ),
          ),
          body: switch (state.status) {
            MarksStatus.initial || MarksStatus.loading => const LoadingView(),
            MarksStatus.failure => ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<MarksCubit>().load(examId),
              ),
            MarksStatus.success => _Content(state: state, examId: examId),
          },
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.examId});

  final MarksState state;
  final int examId;

  @override
  Widget build(BuildContext context) {
    final sheet = state.sheet!;
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pagePadding,
          0,
          AppConstants.pagePadding,
          AppConstants.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: AppColors.border,
              labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              tabs: [Tab(text: 'Enter Marks'), Tab(text: 'Results')],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: sheet.subjects.isEmpty
                  ? const EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'This class has no subjects',
                      message: 'Go to Exams > Subjects and add the subjects of this class first.',
                    )
                  : sheet.students.isEmpty
                      ? const EmptyState(
                          icon: Icons.school_rounded,
                          title: 'No students in this class',
                          message: 'Add students to this class to enter their marks.',
                        )
                      : TabBarView(
                          children: [
                            _EnterMarks(state: state),
                            _Results(state: state, examId: examId),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterMarks extends StatelessWidget {
  const _EnterMarks({required this.state});

  final MarksState state;

  @override
  Widget build(BuildContext context) {
    final String hint;
    final Color color;
    if (state.hasInvalid) {
      hint = 'A mark is more than the total. Fix the red box.';
      color = AppColors.danger;
    } else if (state.hasChanges) {
      hint = 'You have changes that are not saved. Press Save Marks.';
      color = AppColors.warning;
    } else {
      hint = 'Type the marks. Leave a box empty if the student has no marks.';
      color = AppColors.textMuted;
    }
    return Column(
      children: [
        Expanded(child: MarksGrid(state: state)),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Icon(state.hasInvalid ? Icons.error_rounded : Icons.info_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(hint, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
              AppButton(
                label: 'Save Marks',
                icon: Icons.save_rounded,
                isLoading: state.isSaving,
                onPressed: state.hasChanges && !state.hasInvalid
                    ? () => context.read<MarksCubit>().save()
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state, required this.examId});

  final MarksState state;
  final int examId;

  @override
  Widget build(BuildContext context) {
    final results = state.savedResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.hasChanges)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Results below use saved marks only. Save your changes to update them.',
              style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            label: 'Print All Result Cards',
            icon: Icons.print_rounded,
            style: AppButtonStyle.secondary,
            onPressed: () => _open(context, ResultCardPage(examId: examId)),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ResultsList(
            results: results,
            onOpen: (r) => _open(context, ResultCardPage(examId: examId, studentId: r.student.studentId)),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
