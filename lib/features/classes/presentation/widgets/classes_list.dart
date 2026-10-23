import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/school_class.dart';
import '../cubit/classes_cubit.dart';
import '../cubit/classes_state.dart';
import 'class_card.dart';
import 'class_form_dialog.dart';
import 'section_form_dialog.dart';

class ClassesList extends StatelessWidget {
  const ClassesList({super.key, required this.state});

  final ClassesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClassesCubit>();
    final visible = state.visibleClasses;

    if (state.classes.isEmpty) {
      return EmptyState(
        icon: Icons.class_rounded,
        title: 'No classes yet',
        message: 'Add your first class, for example "Class 1".',
        action: AppButton(
          label: 'Add Class',
          icon: Icons.add_rounded,
          onPressed: () => _addClass(context),
        ),
      );
    }
    if (visible.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nothing found',
        message: 'Try a different class or section name.',
      );
    }

    final searching = state.query.trim().isNotEmpty;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final c = visible[index];
        final position = state.classes.indexWhere((x) => x.id == c.id);
        return ClassCard(
          schoolClass: c,
          canMoveUp: !searching && position > 0,
          canMoveDown: !searching && position < state.classes.length - 1,
          onMoveUp: () => cubit.moveClass(c.id, -1),
          onMoveDown: () => cubit.moveClass(c.id, 1),
          onEdit: () => _editClass(context, c),
          onDelete: () => _deleteClass(context, c),
          onAddSection: () => _addSection(context, c),
          onEditSection: (s) => _editSection(context, s),
          onDeleteSection: (s) => _deleteSection(context, s),
        );
      },
    );
  }

  static Future<void> _addClass(BuildContext context) async {
    final cubit = context.read<ClassesCubit>();
    final name = await ClassFormDialog.show(context);
    if (name != null) await cubit.addClass(name);
  }

  Future<void> _editClass(BuildContext context, SchoolClass c) async {
    final cubit = context.read<ClassesCubit>();
    final name = await ClassFormDialog.show(context, initialName: c.name);
    if (name != null) await cubit.renameClass(c.id, name);
  }

  Future<void> _deleteClass(BuildContext context, SchoolClass c) async {
    final cubit = context.read<ClassesCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete ${c.name}?',
      message: 'This cannot be undone.',
    );
    if (ok) await cubit.deleteClass(c.id);
  }

  Future<void> _addSection(BuildContext context, SchoolClass c) async {
    final cubit = context.read<ClassesCubit>();
    final result = await SectionFormDialog.show(
      context,
      teachers: state.teachers,
    );
    if (result != null) {
      await cubit.addSection(c.id, result.name, teacherId: result.teacherId);
    }
  }

  Future<void> _editSection(BuildContext context, SchoolSection s) async {
    final cubit = context.read<ClassesCubit>();
    final result = await SectionFormDialog.show(
      context,
      teachers: state.teachers,
      section: s,
    );
    if (result != null) {
      await cubit.updateSection(s.id, result.name, teacherId: result.teacherId);
    }
  }

  Future<void> _deleteSection(BuildContext context, SchoolSection s) async {
    final cubit = context.read<ClassesCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete Section ${s.name}?',
      message: 'This cannot be undone.',
    );
    if (ok) await cubit.deleteSection(s.id);
  }
}
