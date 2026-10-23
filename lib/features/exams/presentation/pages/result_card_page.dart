import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/result_card.dart';
import '../cubit/result_card_cubit.dart';
import '../cubit/result_card_state.dart';
import '../widgets/result_colors.dart';

/// Result card of one student, or of the whole class when [studentId] is null.
class ResultCardPage extends StatelessWidget {
  const ResultCardPage({super.key, required this.examId, this.studentId});

  final int examId;
  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ResultCardCubit>()..load(examId, studentId: studentId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(studentId == null ? 'All Result Cards' : 'Result Card'),
        ),
        body: BlocBuilder<ResultCardCubit, ResultCardState>(
          builder: (context, state) {
            switch (state.status) {
              case ResultCardStatus.initial:
              case ResultCardStatus.loading:
                return const LoadingView(message: 'Preparing result card...');
              case ResultCardStatus.failure:
                return ErrorView(message: state.errorMessage);
              case ResultCardStatus.success:
                return _Content(state: state);
            }
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final ResultCardState state;

  @override
  Widget build(BuildContext context) {
    final bytes = state.pdfBytes!;
    final single = state.cards.length == 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        8,
        AppConstants.pagePadding,
        AppConstants.pagePadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (single) ...[
            SizedBox(width: 380, child: SingleChildScrollView(child: _History(history: state.history))),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ColoredBox(
                color: AppColors.border,
                child: PdfPreview(
                  build: (_) async => bytes,
                  pdfFileName: single
                      ? 'result_card_${state.cards.first.result.student.admissionNo}.pdf'
                      : 'result_cards_${state.cards.first.exam.name}.pdf',
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  maxPageWidth: 640,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.history});

  final List<ExamSummary> history;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Previous results',
      icon: Icons.history_rounded,
      child: history.isEmpty
          ? Text('No other exams yet.', style: Theme.of(context).textTheme.bodyMedium)
          : Column(
              children: [
                for (final h in history)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.examName, style: Theme.of(context).textTheme.titleMedium),
                              Text(
                                [
                                  h.className,
                                  if (h.examDate != null) AppDateUtils.toDisplay(h.examDate!),
                                ].join('  |  '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${h.obtained}/${h.maxMarks}  (${h.percent.toStringAsFixed(1)}%)'
                                '${h.position == null ? '' : '  |  Position ${h.position}'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        StatusChip(label: h.grade, color: gradeColor(h.grade)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
