import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/attendance_models.dart';
import '../cubit/mark_attendance_cubit.dart';
import '../cubit/mark_attendance_state.dart';
import 'attendance_row.dart';
import 'summary_chips.dart';

/// The list of students with their buttons, and the Save bar.
class MarkAttendanceBody extends StatelessWidget {
  const MarkAttendanceBody({super.key, required this.state});

  final MarkAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MarkAttendanceCubit>();
    if (state.classes.isEmpty) {
      return const EmptyState(
        icon: Icons.class_rounded,
        title: 'No classes yet',
        message: 'Add a class in the Classes section first.',
      );
    }
    if (state.entries.isEmpty) {
      return const EmptyState(
        icon: Icons.school_rounded,
        title: 'No students in this class',
        message: 'Add students to this class to mark attendance.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryChips(
                total: state.entries.length,
                present: state.count(AttendanceStatus.present),
                absent: state.count(AttendanceStatus.absent),
                leave: state.count(AttendanceStatus.leave),
              ),
            ),
            AppButton(
              label: 'All Present',
              icon: Icons.done_all_rounded,
              style: AppButtonStyle.secondary,
              onPressed: () => cubit.markAll(AttendanceStatus.present),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: state.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final entry = state.entries[i];
              return AttendanceRow(
                entry: entry,
                onChanged: (status) => cubit.setStatus(entry.studentId, status),
                onWhatsApp: () => cubit.sendAbsent(entry.studentId),
              );
            },
          ),
        ),
        _SaveBar(state: state),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.state});

  final MarkAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final String hint;
    final Color color;
    if (state.hasChanges) {
      hint = state.alreadyMarked ? 'You changed this day. Press Save.' : 'Not saved yet. Press Save.';
      color = AppColors.warning;
    } else {
      hint = 'Saved for this day.';
      color = AppColors.success;
    }
    return Container(
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
          Icon(state.hasChanges ? Icons.info_rounded : Icons.check_circle_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
          AppButton(
            label: 'Save Attendance',
            icon: Icons.save_rounded,
            isLoading: state.isSaving,
            onPressed: () => context.read<MarkAttendanceCubit>().save(),
          ),
        ],
      ),
    );
  }
}
