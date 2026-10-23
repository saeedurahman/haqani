import 'dart:typed_data';

import 'result_card.dart';

abstract class ResultCardPdfService {
  /// One page per card.
  Future<Uint8List> build(List<ResultCard> cards);
}
