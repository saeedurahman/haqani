import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/exam_models.dart';
import '../../domain/exams_repository.dart';
import 'marks_state.dart';

/// Enter marks for every student of an exam, and see the results.
class MarksCubit extends Cubit<MarksState> {
  MarksCubit(this._repository) : super(const MarksState());

  final ExamsRepository _repository;
  int _examId = 0;

  Future<void> load(int examId) async {
    _examId = examId;
    emit(state.copyWith(status: MarksStatus.loading));
    try {
      final sheet = await _repository.getMarksSheet(examId);
      emit(MarksState(status: MarksStatus.success, sheet: sheet));
    } catch (e) {
      emit(state.copyWith(
        status: MarksStatus.failure,
        errorMessage: e is ExamsException ? e.message : AppStrings.somethingWentWrong,
      ));
    }
  }

  /// Sets what is typed in one box. Null means the box is empty.
  void setMark(int studentId, int subjectId, int? marks) {
    final sheet = state.sheet;
    if (sheet == null) return;
    final saved = sheet.students.firstWhere((s) => s.studentId == studentId).marks[subjectId];
    final edits = Map.of(state.edits);
    if (marks == saved) {
      edits.remove((studentId, subjectId));
    } else {
      edits[(studentId, subjectId)] = marks;
    }
    emit(state.copyWith(edits: edits));
  }

  Future<void> save() async {
    if (!state.hasChanges || state.hasInvalid || state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.saveMarks(_examId, [
        for (final e in state.edits.entries)
          MarkEntry(studentId: e.key.$1, subjectId: e.key.$2, marks: e.value),
      ]);
      final sheet = await _repository.getMarksSheet(_examId);
      emit(MarksState(
        status: MarksStatus.success,
        sheet: sheet,
        feedback: 'Marks saved.',
        feedbackId: state.feedbackId + 1,
      ));
    } on ExamsException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(
      isSaving: false,
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }
}
