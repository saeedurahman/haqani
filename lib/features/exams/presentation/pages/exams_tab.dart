import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../domain/exam_models.dart';
import '../cubit/exams_cubit.dart';
import '../cubit/exams_state.dart';
import '../widgets/exam_form_dialog.dart';
import '../widgets/exam_row.dart';
import 'exam_detail_page.dart';

class ExamsTab extends StatelessWidget {
  const ExamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExamsCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamsCubit>();
    return BlocConsumer<ExamsCubit, ExamsState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppSearchField(width: 320, hint: 'Search exam', onChanged: cubit.search),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey(state.classFilter),
                    initialValue: state.classFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.class_rounded, size: 20, color: AppColors.textMuted),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('All classes')),
                      for (final c in state.classes)
                        DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: cubit.filterByClass,
                  ),
                ),
                AppButton(
                  label: 'Create Exam',
                  icon: Icons.add_rounded,
                  onPressed: state.classes.isEmpty ? null : () => _create(context, state),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _body(context, state)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, ExamsState state) {
    switch (state.status) {
      case ExamsStatus.initial:
      case ExamsStatus.loading:
        return const LoadingView();
      case ExamsStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<ExamsCubit>().load(),
        );
      case ExamsStatus.success:
        if (state.classes.isEmpty) {
          return const EmptyState(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            message: 'Add a class in the Classes section before creating an exam.',
          );
        }
        if (state.exams.isEmpty) {
          return state.hasFilter
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No exams found',
                  message: 'Try another name or class.',
                )
              : EmptyState(
                  icon: Icons.edit_note_rounded,
                  title: 'No exams yet',
                  message: 'Create an exam, add subjects, then enter marks.',
                  action: AppButton(
                    label: 'Create Exam',
                    icon: Icons.add_rounded,
                    onPressed: () => _create(context, state),
                  ),
                );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: state.exams.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final exam = state.exams[i];
            return ExamRow(
              exam: exam,
              onOpen: () => _openExam(context, exam),
              onEdit: () => _edit(context, state, exam),
              onDelete: () => _delete(context, exam),
            );
          },
        );
    }
  }

  Future<void> _create(BuildContext context, ExamsState state) async {
    final cubit = context.read<ExamsCubit>();
    final exam = await ExamFormDialog.show(
      context,
      classes: state.classes,
      initialClassId: state.classFilter,
    );
    if (exam != null) await cubit.saveExam(exam);
  }

  Future<void> _edit(BuildContext context, ExamsState state, Exam exam) async {
    final cubit = context.read<ExamsCubit>();
    final changed = await ExamFormDialog.show(context, classes: state.classes, exam: exam);
    if (changed != null) await cubit.saveExam(changed);
  }

  Future<void> _delete(BuildContext context, Exam exam) async {
    final cubit = context.read<ExamsCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete ${exam.name}?',
      message: 'This cannot be undone. An exam that has marks cannot be deleted.',
    );
    if (ok) await cubit.deleteExam(exam.id);
  }

  Future<void> _openExam(BuildContext context, Exam exam) async {
    final cubit = context.read<ExamsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ExamDetailPage(examId: exam.id)),
    );
    await cubit.refresh();
  }
}
