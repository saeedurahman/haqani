import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/admissions/data/leaving_certificate_pdf.dart';
import 'package:haqani/features/admissions/domain/leaving_certificate.dart';

import '../../support/load_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  final certificate = LeavingCertificate(
    schoolName: 'Rozatul Atfal',
    schoolAddress: 'Iqra Schools Foundation, Lahore',
    admissionNo: '105',
    studentName: 'Ayesha Khan',
    fatherName: 'Imran Khan',
    gender: 'female',
    dob: DateTime(2018, 3, 5),
    attendedFrom: DateTime(2024, 4, 1),
    attendedTo: DateTime(2026, 6, 30),
    className: 'Class 2',
    exam: 'Annual 2026',
    promotedClass: 'Class 3',
    admissionDate: DateTime(2024, 4, 1),
    attendance: '92% (184 of 200 days)',
    issueDate: DateTime(2026, 7, 1),
  );

  test('builds a one page PDF', () async {
    final bytes = await LeavingCertificatePdf().build(certificate);

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
    final text = String.fromCharCodes(bytes);
    expect(RegExp(r'/Type\s*/Page\b').allMatches(text).length, 1);
  });

  test('works with empty values, Urdu names and unset dates', () async {
    final bytes = await LeavingCertificatePdf().build(const LeavingCertificate(
      schoolName: 'Rozatul Atfal',
      schoolAddress: '',
      admissionNo: '1',
      studentName: 'عائشہ خان',
      fatherName: '',
      gender: 'male',
    ));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  final urduCertificate = LeavingCertificate(
    schoolName: 'روضۃ الاطفال',
    schoolAddress: 'اقراء سکولز فاؤنڈیشن، لاہور',
    admissionNo: '105',
    studentName: 'زاہد خان',
    fatherName: 'عبداللہ خان',
    gender: 'male',
    dob: DateTime(2018, 3, 5),
    className: 'کلاس دوم',
    exam: 'Annual 2026',
    promotedClass: 'کلاس سوم',
    admissionDate: DateTime(2024, 4, 1),
    attendance: '92%',
    discipline: 'اچھا',
    issueDate: DateTime(2026, 7, 1),
  );

  test('Urdu text is drawn as pictures, on one page, and English-only has none', () async {
    final urdu = await LeavingCertificatePdf().build(urduCertificate);
    final english = await LeavingCertificatePdf().build(certificate);

    final text = String.fromCharCodes(urdu);
    expect(RegExp(r'/Type\s*/Page\b').allMatches(text).length, 1);
    expect(RegExp('/Subtype/Image').allMatches(text).length, greaterThan(8));
    expect(String.fromCharCodes(english).contains('/Subtype/Image'), isFalse);
  });

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['CERT_SAMPLE_PATH'];
    if (path == null) return;
    File(path).writeAsBytesSync(await LeavingCertificatePdf().build(urduCertificate));
  });
}
