import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/admissions/data/leaving_certificate_pdf.dart';
import 'package:haqani/features/admissions/domain/leaving_certificate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['CERT_SAMPLE_PATH'];
    if (path == null) return;
    File(path).writeAsBytesSync(await LeavingCertificatePdf().build(certificate));
  });
}
