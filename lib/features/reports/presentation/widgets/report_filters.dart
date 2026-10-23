import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/month_switcher.dart';
import '../../../attendance/presentation/widgets/class_section_picker.dart';
import '../../../fees/domain/fee_models.dart';
import '../../domain/report_kind.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';

/// The choices that belong to the report being shown.
class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key, required this.state});

  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    final now = DateTime.now();
    final isCurrentMonth = state.month.year == now.year && state.month.month == now.month;

    switch (state.kind) {
      case ReportKind.students:
        return const SizedBox.shrink();
      case ReportKind.admissions:
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 230,
              child: AppDateField(
                label: 'From',
                value: state.from,
                lastDate: now,
                onChanged: (d) => cubit.setRange(from: d, to: state.to),
              ),
            ),
            SizedBox(
              width: 230,
              child: AppDateField(
                label: 'To',
                value: state.to,
                lastDate: now,
                onChanged: (d) => cubit.setRange(from: state.from, to: d),
              ),
            ),
          ],
        );
      case ReportKind.attendance:
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ClassSectionPicker(
              classes: state.classes,
              classId: state.classId,
              sectionId: state.sectionId,
              onClassChanged: cubit.selectClass,
              onSectionChanged: cubit.selectSection,
            ),
            MonthSwitcher(month: state.month, onMove: cubit.moveMonth, canGoNext: !isCurrentMonth),
          ],
        );
      case ReportKind.fees:
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ClassDropdown(state: state, onChanged: cubit.selectClass),
            MonthSwitcher(month: state.month, onMove: cubit.moveMonth, canGoNext: !isCurrentMonth),
            for (final (label, status) in const [
              ('All', null),
              ('Paid', FeeStatus.paid),
              ('Partial', FeeStatus.partial),
              ('Unpaid', FeeStatus.unpaid),
            ])
              ChoiceChip(
                label: Text(label),
                selected: state.feeStatus == status,
                onSelected: (_) => cubit.setFeeStatus(status),
              ),
          ],
        );
      case ReportKind.defaulters:
        return _ClassDropdown(state: state, onChanged: cubit.selectClass);
      case ReportKind.examResults:
        return SizedBox(
          width: 420,
          child: DropdownButtonFormField<int>(
            key: ValueKey(state.examId),
            initialValue: state.examId,
            isExpanded: true,
            hint: const Text('Choose an exam'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.edit_note_rounded, size: 20, color: AppColors.textMuted),
            ),
            items: [
              for (final e in state.exams)
                DropdownMenuItem(value: e.id, child: Text('${e.name}  (${e.className})')),
            ],
            onChanged: cubit.selectExam,
          ),
        );
      case ReportKind.studentHistory:
        return _StudentPicker(state: state);
    }
  }
}

class _ClassDropdown extends StatelessWidget {
  const _ClassDropdown({required this.state, required this.onChanged});

  final ReportsState state;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<int?>(
        key: ValueKey(state.classId),
        initialValue: state.classId,
        isExpanded: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.class_rounded, size: 20, color: AppColors.textMuted),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All classes')),
          for (final c in state.classes) DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _StudentPicker extends StatelessWidget {
  const _StudentPicker({required this.state});

  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    final chosen = state.student;
    if (chosen != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          avatar: const Icon(Icons.person_rounded, size: 18),
          label: Text(
            '${chosen.name}  |  ID ${chosen.admissionNo}  |  ${chosen.classLabel}',
            style: const TextStyle(fontFamilyFallback: AppTheme.fontFallback),
          ),
          deleteIcon: const Icon(Icons.close_rounded, size: 18),
          onDeleted: () => cubit.selectStudent(null),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          width: 460,
          hint: 'Find a student by name, father name or ID',
          onChanged: cubit.searchStudents,
        ),
        if (state.studentMatches.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final s in state.studentMatches.take(8))
                ActionChip(
                  avatar: const Icon(Icons.person_rounded, size: 18),
                  label: Text(
                    '${s.name}  |  ID ${s.admissionNo}',
                    style: const TextStyle(fontFamilyFallback: AppTheme.fontFallback),
                  ),
                  onPressed: () => cubit.selectStudent(s),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
