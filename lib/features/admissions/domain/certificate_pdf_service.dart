import 'dart:typed_data';

import 'leaving_certificate.dart';

abstract class CertificatePdfService {
  Future<Uint8List> build(LeavingCertificate certificate);
}
