import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/exam_models.dart';
import '../../domain/result_calculator.dart';
import '../cubit/marks_cubit.dart';
import '../cubit/marks_state.dart';
import 'mark_cell.dart';
import 'result_colors.dart';

const _nameWidth = 230.0;
const _cellWidth = 104.0;
const _totalWidth = 96.0;
const _percentWidth = 84.0;
const _gradeWidth = 70.0;

/// Students down the side, subjects across. Totals and grades update while typing.
class MarksGrid extends StatelessWidget {
  const MarksGrid({super.key, required this.state});

  final MarksState state;

  @override
  Widget build(BuildContext context) {
    final sheet = state.sheet!;
    final results = state.liveResults;
    final width = 40 +
        _nameWidth +
        _cellWidth * sheet.subjects.length +
        _totalWidth +
        _percentWidth +
        _gradeWidth +
        24;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = width < constraints.maxWidth ? constraints.maxWidth : width;
        return Scrollbar(
          notificationPredicate: (n) => n.depth == 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: gridWidth,
              child: Column(
                children: [
                  _Header(subjects: sheet.subjects),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: sheet.students.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _StudentRow(
                        index: i,
                        student: sheet.students[i],
                        subjects: sheet.subjects,
                        result: results[i],
                        state: state,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted);
    Widget cell(String text, double w, {TextAlign align = TextAlign.center}) =>
        SizedBox(width: w, child: Text(text, textAlign: align, style: style, maxLines: 2));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const SizedBox(width: 40),
          cell('Student', _nameWidth, align: TextAlign.left),
          for (final s in subjects) cell('${s.name}\n(${s.totalMarks})', _cellWidth),
          cell('Total', _totalWidth),
          cell('%', _percentWidth),
          cell('Grade', _gradeWidth),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.index,
    required this.student,
    required this.subjects,
    required this.result,
    required this.state,
  });

  final int index;
  final StudentMarks student;
  final List<Subject> subjects;
  final StudentResult result;
  final MarksState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MarksCubit>();
    final marks = state.marksOf(student);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${index + 1}', style: const TextStyle(color: AppColors.textMuted)),
          ),
          SizedBox(
            width: _nameWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppTheme.fontFallback,
                      ),
                ),
                Text('ID ${student.admissionNo}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          for (final s in subjects)
            SizedBox(
              width: _cellWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: MarkCell(
                  key: ValueKey((student.studentId, s.id)),
                  value: marks[s.id],
                  totalMarks: s.totalMarks,
                  invalid: state.isInvalid((student.studentId, s.id)),
                  onChanged: (v) => cubit.setMark(student.studentId, s.id, v),
                ),
              ),
            ),
          SizedBox(
            width: _totalWidth,
            child: Text(
              result.status == ResultStatus.notEntered ? '-' : '${result.obtained}/${result.maxMarks}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: _percentWidth,
            child: Text(
              result.status == ResultStatus.notEntered ? '-' : '${result.percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: _gradeWidth,
            child: Center(
              child: StatusChip(label: result.grade, color: gradeColor(result.grade)),
            ),
          ),
        ],
      ),
    );
  }
}
