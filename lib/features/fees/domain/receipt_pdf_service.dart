import 'dart:typed_data';

import 'fee_models.dart';

abstract class ReceiptPdfService {
  Future<Uint8List> build(FeeReceipt receipt);
}
