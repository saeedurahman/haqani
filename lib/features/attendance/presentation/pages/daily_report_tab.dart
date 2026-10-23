import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../students/presentation/widgets/student_avatar.dart';
import '../../domain/attendance_models.dart';
import '../cubit/daily_report_cubit.dart';
import '../cubit/daily_report_state.dart';
import '../widgets/class_section_picker.dart';
import '../widgets/status_colors.dart';
import '../widgets/summary_chips.dart';

class DailyReportTab extends StatelessWidget {
  const DailyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DailyReportCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DailyReportCubit>();
    return BlocBuilder<DailyReportCubit, DailyReportState>(
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
                SizedBox(
                  width: 240,
                  child: AppDateField(
                    label: 'Date',
                    clearable: false,
                    value: state.date,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime.now(),
                    onChanged: (d) {
                      if (d != null) cubit.selectDate(d);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  Widget _content(BuildContext context, DailyReportState state) {
    switch (state.status) {
      case DailyReportStatus.initial:
      case DailyReportStatus.loading:
        return const LoadingView();
      case DailyReportStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<DailyReportCubit>().load(),
        );
      case DailyReportStatus.success:
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
            message: 'There is nothing to show for this class.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryChips(
              total: state.entries.length,
              present: state.count(AttendanceStatus.present),
              absent: state.count(AttendanceStatus.absent),
              leave: state.count(AttendanceStatus.leave),
              notMarked: state.count(null),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _ReportRow(entry: state.entries[i]),
              ),
            ),
          ],
        );
    }
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.entry});

  final AttendanceEntry entry;

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
          StudentAvatar(name: entry.name, gender: entry.gender, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              entry.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamilyFallback: AppTheme.fontFallback,
                  ),
            ),
          ),
          Text('ID ${entry.admissionNo}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 24),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusChip(
                label: AttendanceStatus.label(entry.status),
                color: attendanceColor(entry.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
