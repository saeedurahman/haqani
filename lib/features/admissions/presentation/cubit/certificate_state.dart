import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/leaving_certificate.dart';

enum CertificateStatus { initial, loading, success, failure }

class CertificateState extends Equatable {
  const CertificateState({
    this.status = CertificateStatus.initial,
    this.certificate,
    this.pdfBytes,
    this.errorMessage,
  });

  final CertificateStatus status;
  final LeavingCertificate? certificate;

  /// Latest PDF made from [certificate]. Null while it is being drawn.
  final Uint8List? pdfBytes;
  final String? errorMessage;

  CertificateState copyWith({
    CertificateStatus? status,
    LeavingCertificate? certificate,
    Uint8List? pdfBytes,
    String? errorMessage,
  }) {
    return CertificateState(
      status: status ?? this.status,
      certificate: certificate ?? this.certificate,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, certificate, pdfBytes, errorMessage];
}
