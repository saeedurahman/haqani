import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/attendance_models.dart';
import '../cubit/monthly_report_cubit.dart';
import '../cubit/monthly_report_state.dart';
import '../widgets/class_section_picker.dart';
import '../widgets/student_month_dialog.dart';

class MonthlyReportTab extends StatelessWidget {
  const MonthlyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MonthlyReportCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MonthlyReportCubit>();
    return BlocConsumer<MonthlyReportCubit, MonthlyReportState>(
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
                  classes: state.classes,
                  classId: state.classId,
                  sectionId: state.sectionId,
                  onClassChanged: cubit.selectClass,
                  onSectionChanged: cubit.selectSection,
                ),
                _MonthSwitcher(month: state.month, onMove: cubit.moveMonth),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  Widget _content(BuildContext context, MonthlyReportState state) {
    switch (state.status) {
      case MonthlyReportStatus.initial:
      case MonthlyReportStatus.loading:
        return const LoadingView();
      case MonthlyReportStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<MonthlyReportCubit>().load(),
        );
      case MonthlyReportStatus.success:
        if (state.classes.isEmpty) {
          return const EmptyState(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            message: 'Add a class in the Classes section first.',
          );
        }
        if (state.rows.isEmpty) {
          return const EmptyState(
            icon: Icons.school_rounded,
            title: 'No students in this class',
            message: 'There is nothing to show for this class.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: state.rows.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _MonthRow(
            row: state.rows[i],
            onTap: () => StudentMonthDialog.show(
              context,
              state.rows[i],
              state.month,
              onWhatsApp: () => context.read<MonthlyReportCubit>().sendMonth(state.rows[i]),
            ),
          ),
        );
    }
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.month, required this.onMove});

  final DateTime month;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Previous month',
          onPressed: () => onMove(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(
          width: 170,
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Next month',
          onPressed: isCurrent ? null : () => onMove(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.row, required this.onTap});

  final MonthlyAttendanceRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentColor = row.markedDays == 0
        ? AppColors.textMuted
        : row.percent >= 85
            ? AppColors.success
            : row.percent >= 70
                ? AppColors.warning
                : AppColors.danger;
    final muted = Theme.of(context).textTheme.bodyMedium;
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              row.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamilyFallback: AppTheme.fontFallback,
                  ),
            ),
          ),
          Expanded(flex: 2, child: Text('ID ${row.admissionNo}', style: muted)),
          _Count(label: 'Present', value: row.present, color: AppColors.success),
          _Count(label: 'Absent', value: row.absent, color: AppColors.danger),
          _Count(label: 'Leave', value: row.leave, color: AppColors.warning),
          SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(
                label: row.markedDays == 0 ? '-' : '${row.percent}%',
                color: percentColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Text('$value', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
