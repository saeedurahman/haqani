import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/utils/pdf_school_header.dart';
import 'package:haqani/features/admissions/data/leaving_certificate_pdf.dart';
import 'package:haqani/features/admissions/domain/leaving_certificate.dart';
import 'package:haqani/features/exams/data/result_card_pdf.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/exams/domain/result_calculator.dart';
import 'package:haqani/features/exams/domain/result_card.dart';
import 'package:haqani/features/fees/data/fee_receipt_pdf.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:haqani/features/reports/data/report_pdf.dart';
import 'package:haqani/features/reports/domain/report_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late String logo;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('pdf_logo_');
    logo = (File('${temp.path}/logo.png')
          ..writeAsBytesSync(base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==')))
        .path;
  });

  tearDown(() => temp.delete(recursive: true));

  bool hasImage(List<int> pdf) => RegExp(r'/Subtype\s*/Image').hasMatch(String.fromCharCodes(pdf));

  test('loadPdfLogo: a real picture, nothing, a missing file and a broken file', () async {
    expect(await loadPdfLogo(logo), isNotNull);
    expect(await loadPdfLogo(null), isNull);
    expect(await loadPdfLogo('${temp.path}/missing.png'), isNull);
    final broken = File('${temp.path}/broken.png')..writeAsStringSync('not a picture');
    // A broken picture must not crash the print: it counts as no logo.
    expect(await loadPdfLogo(broken.path), isNull);
  });

  group('fee receipt', () {
    FeeReceipt receipt({String? logoPath}) => FeeReceipt(
          receiptNo: '1',
          date: DateTime(2026, 5, 10),
          schoolName: 'Iqra Model School',
          schoolAddress: 'Lahore',
          schoolPhone: '042-1234567',
          logoPath: logoPath,
          lines: [
            ReceiptLine(
              voucher: FeeVoucher(
                id: 1,
                date: DateTime(2026, 5, 10),
                student: const FeeStudent(id: 1, name: 'Ali', admissionNo: '1'),
                forMonth: '2026-05',
                monthlyFee: 1500,
                total: 1500,
                paidAmount: 1500,
                status: 'paid',
              ),
              receivedNow: 1500,
            ),
          ],
        );

    test('prints the logo when there is one, and nothing extra when there is not', () async {
      final withLogo = await FeeReceiptPdf().build(receipt(logoPath: logo));
      final without = await FeeReceiptPdf().build(receipt());

      expect(hasImage(withLogo), isTrue);
      expect(hasImage(without), isFalse);
    });

    test('a logo path that no longer exists does not stop the receipt', () async {
      final bytes = await FeeReceiptPdf().build(receipt(logoPath: '${temp.path}/gone.png'));

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(hasImage(bytes), isFalse);
    });
  });

  test('leaving certificate prints the logo', () async {
    LeavingCertificate cert(String? path) => LeavingCertificate(
          schoolName: 'Iqra Model School',
          schoolAddress: 'Lahore',
          schoolPhone: '042-1234567',
          logoPath: path,
          admissionNo: '1',
          studentName: 'Ali',
          fatherName: 'Raza',
          gender: 'male',
        );

    expect(hasImage(await LeavingCertificatePdf().build(cert(logo))), isTrue);
    expect(hasImage(await LeavingCertificatePdf().build(cert(null))), isFalse);
  });

  test('result card prints the logo', () async {
    ResultCard card(String? path) {
      const subjects = [Subject(id: 1, classId: 1, name: 'English')];
      const student = StudentMarks(studentId: 1, name: 'Ali', admissionNo: '1', marks: {1: 80});
      final sheet = MarksSheet(
        exam: const Exam(id: 1, name: 'Annual', classId: 1, className: 'Class 1'),
        subjects: subjects,
        students: const [student],
      );
      final results = ResultCalculator.compute(subjects, const [student]);
      return ResultCard.from(
        school: SchoolInfo(name: 'Iqra Model School', address: 'Lahore', phone: '042-1', logoPath: path),
        sheet: sheet,
        result: results.single,
        all: results,
      );
    }

    expect(hasImage(await ResultCardPdf().build([card(logo)])), isTrue);
    expect(hasImage(await ResultCardPdf().build([card(null)])), isFalse);
  });

  test('report prints the logo', () async {
    const doc = ReportDocument(
      title: 'Students Report',
      tables: [
        ReportTable(columns: [ReportColumn('A')], rows: [['x']]),
      ],
    );

    final withLogo = await ReportPdf().build(doc, SchoolInfo(name: 'S', phone: '042-1', logoPath: logo));
    final without = await ReportPdf().build(doc, const SchoolInfo(name: 'S'));

    expect(hasImage(withLogo), isTrue);
    expect(hasImage(without), isFalse);
  });
}
