import 'dart:typed_data';

import '../../exams/domain/exam_models.dart';
import 'report_models.dart';

abstract class ReportPdfService {
  Future<Uint8List> build(ReportDocument document, SchoolInfo school);
}
