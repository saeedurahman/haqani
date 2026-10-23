import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../../attendance/presentation/widgets/class_section_picker.dart';
import '../../domain/exam_models.dart';
import '../cubit/subjects_cubit.dart';
import '../cubit/subjects_state.dart';
import '../widgets/subject_form_dialog.dart';

class SubjectsTab extends StatelessWidget {
  const SubjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubjectsCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SubjectsCubit>();
    return BlocConsumer<SubjectsCubit, SubjectsState>(
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
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                ClassSectionPicker(
                  classes: [for (final c in state.classes) c.withoutSections()],
                  classId: state.classId,
                  sectionId: null,
                  onClassChanged: cubit.selectClass,
                  onSectionChanged: (_) {},
                ),
                AppButton(
                  label: 'Add Subject',
                  icon: Icons.add_rounded,
                  onPressed: state.classId == null ? null : () => _add(context),
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

  Widget _body(BuildContext context, SubjectsState state) {
    switch (state.status) {
      case SubjectsStatus.initial:
      case SubjectsStatus.loading:
        return const LoadingView();
      case SubjectsStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<SubjectsCubit>().load(),
        );
      case SubjectsStatus.success:
        if (state.classes.isEmpty) {
          return const EmptyState(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            message: 'Add a class in the Classes section first.',
          );
        }
        if (state.subjects.isEmpty) {
          return EmptyState(
            icon: Icons.menu_book_rounded,
            title: 'No subjects for this class',
            message: 'Add the subjects of this class, for example English, Urdu and Math.',
            action: AppButton(
              label: 'Add Subject',
              icon: Icons.add_rounded,
              onPressed: () => _add(context),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final s in state.subjects) ...[
              _SubjectRow(
                subject: s,
                onEdit: () => _edit(context, s),
                onDelete: () => _delete(context, s),
              ),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Total of all subjects: ${state.totalMarks} marks',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        );
    }
  }

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<SubjectsCubit>();
    final result = await SubjectFormDialog.show(context);
    if (result != null) await cubit.save(name: result.name, totalMarks: result.totalMarks);
  }

  Future<void> _edit(BuildContext context, Subject subject) async {
    final cubit = context.read<SubjectsCubit>();
    final result = await SubjectFormDialog.show(context, subject: subject);
    if (result != null) {
      await cubit.save(id: subject.id, name: result.name, totalMarks: result.totalMarks);
    }
  }

  Future<void> _delete(BuildContext context, Subject subject) async {
    final cubit = context.read<SubjectsCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete ${subject.name}?',
      message: 'This cannot be undone. A subject that has marks cannot be deleted.',
    );
    if (ok) await cubit.delete(subject.id);
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject, required this.onEdit, required this.onDelete});

  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(subject.name, style: Theme.of(context).textTheme.titleMedium)),
          Text('${subject.totalMarks} marks', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Edit subject',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 20),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'Delete subject',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
