import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/admissions_repository.dart';
import '../../domain/certificate_pdf_service.dart';
import '../../domain/leaving_certificate.dart';
import 'certificate_state.dart';

class CertificateCubit extends Cubit<CertificateState> {
  CertificateCubit(this._repository, this._pdf, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(const CertificateState());

  final AdmissionsRepository _repository;
  final CertificatePdfService _pdf;
  final DateTime Function() _clock;

  /// Only the newest drawing may update the preview.
  int _drawing = 0;

  Future<void> load(int studentId) async {
    emit(state.copyWith(status: CertificateStatus.loading));
    try {
      final certificate = await _repository.getCertificateDefaults(studentId, _clock());
      emit(state.copyWith(status: CertificateStatus.success, certificate: certificate));
      await _draw(certificate);
    } catch (_) {
      emit(state.copyWith(
        status: CertificateStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  /// Called when the user changes any value. Redraws the preview.
  Future<void> update(LeavingCertificate certificate) async {
    emit(state.copyWith(certificate: certificate));
    await _draw(certificate);
  }

  Future<void> _draw(LeavingCertificate certificate) async {
    final id = ++_drawing;
    try {
      final bytes = await _pdf.build(certificate);
      if (id != _drawing) return;
      emit(state.copyWith(pdfBytes: bytes));
    } catch (_) {
      if (id != _drawing) return;
      emit(state.copyWith(
        status: CertificateStatus.failure,
        errorMessage: 'The certificate could not be created.',
      ));
    }
  }
}
