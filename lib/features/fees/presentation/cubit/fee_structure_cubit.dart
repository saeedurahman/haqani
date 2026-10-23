import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/fee_models.dart';
import '../../domain/fees_repository.dart';
import 'fee_structure_state.dart';

class FeeStructureCubit extends Cubit<FeeStructureState> {
  FeeStructureCubit(this._repository) : super(const FeeStructureState());

  final FeesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: FeeStructureStatus.loading));
    try {
      final fees = await _repository.getFeeStructures();
      emit(state.copyWith(status: FeeStructureStatus.success, fees: fees));
    } catch (_) {
      emit(state.copyWith(
        status: FeeStructureStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> save(int classId, {required int monthly, required int annual, required int admission}) async {
    try {
      await _repository.saveFeeStructure(classId, monthly, annual, admission);
      final fees = await _repository.getFeeStructures();
      final name = fees.firstWhere((f) => f.classId == classId).className;
      emit(state.copyWith(
        fees: fees,
        feedback: 'Fees saved for $name.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on FeesException catch (e) {
      _emitError(e.message);
    } catch (_) {
      _emitError(AppStrings.somethingWentWrong);
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(
      feedback: message,
      feedbackIsError: true,
      feedbackId: state.feedbackId + 1,
    ));
  }
}
