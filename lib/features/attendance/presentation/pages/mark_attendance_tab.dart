import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../cubit/mark_attendance_cubit.dart';
import '../cubit/mark_attendance_state.dart';
import '../widgets/class_section_picker.dart';
import '../widgets/mark_attendance_body.dart';

class MarkAttendanceTab extends StatefulWidget {
  const MarkAttendanceTab({super.key});

  @override
  State<MarkAttendanceTab> createState() => _MarkAttendanceTabState();
}

/// Keeps what the teacher already tapped when they look at another tab.
class _MarkAttendanceTabState extends State<MarkAttendanceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => getIt<MarkAttendanceCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MarkAttendanceCubit>();
    return BlocConsumer<MarkAttendanceCubit, MarkAttendanceState>(
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

  Widget _content(BuildContext context, MarkAttendanceState state) {
    switch (state.status) {
      case MarkAttendanceStatus.initial:
      case MarkAttendanceStatus.loading:
        return const LoadingView();
      case MarkAttendanceStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<MarkAttendanceCubit>().load(),
        );
      case MarkAttendanceStatus.success:
        return MarkAttendanceBody(state: state);
    }
  }
}
