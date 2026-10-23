import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ReportPdfStatus { initial, loading, success, failure }

class ReportPdfState extends Equatable {
  const ReportPdfState({
    this.status = ReportPdfStatus.initial,
    this.bytes,
    this.errorMessage,
  });

  final ReportPdfStatus status;
  final Uint8List? bytes;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, bytes, errorMessage];
}
