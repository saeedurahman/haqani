import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/exam_models.dart';
import '../../domain/exams_repository.dart';
import '../../domain/result_calculator.dart';
import '../../domain/result_card.dart';
import '../../domain/result_card_pdf_service.dart';
import 'result_card_state.dart';

class ResultCardCubit extends Cubit<ResultCardState> {
  ResultCardCubit(this._repository, this._pdf) : super(const ResultCardState());

  final ExamsRepository _repository;
  final ResultCardPdfService _pdf;

  /// Pass [studentId] for one card, or null for every student of the exam.
  Future<void> load(int examId, {int? studentId}) async {
    emit(state.copyWith(status: ResultCardStatus.loading));
    try {
      final sheet = await _repository.getMarksSheet(examId);
      final school = await _repository.getSchoolInfo();
      final results = ResultCalculator.compute(sheet.subjects, sheet.students);

      final chosen = studentId == null
          ? results.where((r) => r.status != ResultStatus.notEntered).toList()
          : results.where((r) => r.student.studentId == studentId).toList();
      if (chosen.isEmpty) {
        emit(state.copyWith(
          status: ResultCardStatus.failure,
          errorMessage: studentId == null
              ? 'No marks are entered yet, so there is nothing to print.'
              : 'This student was not found in the exam.',
        ));
        return;
      }
      final cards = [
        for (final r in chosen)
          ResultCard.from(school: school, sheet: sheet, result: r, all: results),
      ];
      final history = studentId == null ? <ExamSummary>[] : await _repository.getStudentHistory(studentId);
      final bytes = await _pdf.build(cards);
      emit(state.copyWith(
        status: ResultCardStatus.success,
        cards: cards,
        history: history,
        pdfBytes: bytes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ResultCardStatus.failure,
        errorMessage: e is ExamsException ? e.message : AppStrings.somethingWentWrong,
      ));
    }
  }
}
