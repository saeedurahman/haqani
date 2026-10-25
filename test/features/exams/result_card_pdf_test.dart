import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/exams/data/result_card_pdf.dart';
import 'package:haqani/features/exams/domain/exam_models.dart';
import 'package:haqani/features/exams/domain/result_calculator.dart';
import 'package:haqani/features/exams/domain/result_card.dart';

import '../../support/load_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  const subjects = [
    Subject(id: 1, classId: 1, name: 'English'),
    Subject(id: 2, classId: 1, name: 'Urdu / اردو'),
    Subject(id: 3, classId: 1, name: 'Math', totalMarks: 50),
  ];

  List<ResultCard> cards(
    List<StudentMarks> students, {
    String school = 'Rozatul Atfal',
  }) {
    final sheet = MarksSheet(
      exam: Exam(
        id: 1,
        name: 'Annual 2026',
        classId: 1,
        className: 'Class 1',
        date: DateTime(2026, 5, 20),
      ),
      subjects: subjects,
      students: students,
    );
    final results = ResultCalculator.compute(subjects, students);
    return [
      for (final r in results)
        ResultCard.from(
          school: SchoolInfo(
            name: school,
            address: 'Iqra Schools Foundation, Lahore',
          ),
          sheet: sheet,
          result: r,
          all: results,
        ),
    ];
  }

  const ayesha = StudentMarks(
    studentId: 1,
    name: 'عائشہ خان',
    admissionNo: '105',
    fatherName: 'Imran Khan',
    sectionName: 'A',
    marks: {1: 88, 2: 79, 3: 41},
  );
  const ali = StudentMarks(
    studentId: 2,
    name: 'Ali Raza',
    admissionNo: '106',
    marks: {1: 30, 2: 45},
  );

  test('builds a one page PDF for one student', () async {
    final bytes = await ResultCardPdf().build(cards([ayesha]));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length,
      1,
    );
  });

  test('builds one page per student, including incomplete results', () async {
    final bytes = await ResultCardPdf().build(cards([ayesha, ali]));

    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length,
      2,
    );
  });

  test('Urdu names are drawn as pictures on every card', () async {
    final urdu = String.fromCharCodes(
      await ResultCardPdf().build(cards([ayesha, ali], school: 'روضۃ الاطفال')),
    );

    expect(RegExp(r'/Type\s*/Page\b').allMatches(urdu).length, 2);
    expect(RegExp('/Subtype/Image').allMatches(urdu).length, greaterThan(4));
  });

  test('writes a sample file for visual checking when asked', () async {
    final path = Platform.environment['CARD_SAMPLE_PATH'];
    if (path == null) return;
    File(path).writeAsBytesSync(
      await ResultCardPdf().build(cards([ayesha, ali], school: 'روضۃ الاطفال')),
    );
  });
}
