import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/whatsapp_messages.dart';
import '../../domain/students_exception.dart';
import '../../domain/students_repository.dart';
import 'student_detail_state.dart';

class StudentDetailCubit extends Cubit<StudentDetailState> {
  StudentDetailCubit(this._repository, this._whatsApp, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const StudentDetailState());

  final StudentsRepository _repository;
  final WhatsAppService _whatsApp;
  final DateTime Function() _clock;

  Future<void> load(int studentId) async {
    if (state.student == null) {
      emit(state.copyWith(status: StudentDetailStatus.loading));
    }
    try {
      final student = await _repository.getStudent(studentId);
      if (student == null) {
        emit(state.copyWith(
          status: StudentDetailStatus.failure,
          errorMessage: 'This student was not found.',
        ));
        return;
      }
      emit(state.copyWith(
        status: StudentDetailStatus.success,
        student: student,
        documents: await _repository.getDocuments(studentId),
        history: await _repository.getHistory(studentId),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StudentDetailStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> markAsLeft() {
    final student = state.student!;
    return _run(
      () => _repository.markAsLeft(student.id, _clock()),
      '${student.name} is marked as left.',
    );
  }

  Future<void> reactivate() {
    final student = state.student!;
    return _run(
      () => _repository.reactivate(student.id),
      '${student.name} is active again.',
    );
  }

  /// Opens WhatsApp with a short message about the student for the parent.
  Future<void> sendWhatsApp() async {
    final student = state.student;
    if (student == null) return;
    final attendance = state.history.attendance;
    final fees = [...state.history.fees]..sort((a, b) => b.forMonth.compareTo(a.forMonth));
    final result = await _whatsApp.sendToParent(
      studentId: student.id,
      body: WhatsAppMessages.studentUpdate(
        studentName: student.name,
        classLabel: student.classLabel,
        attendancePercent: attendance.isEmpty
            ? null
            : (state.history.countAttendance('present') * 100 / attendance.length).round(),
        // The newest voucher already includes older unpaid amounts.
        feeDue: fees.isEmpty ? null : fees.first.due,
      ),
    );
    emit(state.copyWith(
      feedback: result.userMessage,
      feedbackIsError: result.isError,
      feedbackId: state.feedbackId + 1,
    ));
  }

  Future<void> addDocument(String title, String sourcePath) => _run(
        () => _repository.addDocument(state.student!.id, title, sourcePath),
        'Document added.',
      );

  Future<void> deleteDocument(int documentId) => _run(
        () => _repository.deleteDocument(documentId),
        'Document removed.',
      );

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action();
      final id = state.student!.id;
      final student = await _repository.getStudent(id);
      emit(state.copyWith(
        student: student,
        documents: await _repository.getDocuments(id),
        feedback: success,
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on StudentsException catch (e) {
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
