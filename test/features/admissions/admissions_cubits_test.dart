import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/admissions/domain/admissions_repository.dart';
import 'package:haqani/features/admissions/domain/certificate_pdf_service.dart';
import 'package:haqani/features/admissions/domain/leaving_certificate.dart';
import 'package:haqani/features/admissions/presentation/cubit/admission_form_cubit.dart';
import 'package:haqani/features/admissions/presentation/cubit/admission_form_state.dart';
import 'package:haqani/features/admissions/presentation/cubit/admissions_cubit.dart';
import 'package:haqani/features/admissions/presentation/cubit/admissions_state.dart';
import 'package:haqani/features/admissions/presentation/cubit/certificate_cubit.dart';
import 'package:haqani/features/admissions/presentation/cubit/certificate_state.dart';
import 'package:haqani/features/students/domain/student.dart';
import 'package:haqani/features/students/domain/student_extras.dart';
import 'package:haqani/features/students/domain/students_exception.dart';

const _certificate = LeavingCertificate(
  schoolName: 'Test School',
  schoolAddress: '',
  admissionNo: '5',
  studentName: 'Ali',
  fatherName: 'Raza',
  gender: 'male',
);

class _FakeRepository implements AdmissionsRepository {
  bool fail = false;
  String? admitError;
  String? lastQuery;
  DateTime? lastFrom;
  DateTime? lastTo;
  Student? admittedInput;

  @override
  Future<List<Student>> getAdmissions({String query = '', DateTime? from, DateTime? to}) async {
    if (fail) throw Exception('db');
    lastQuery = query;
    lastFrom = from;
    lastTo = to;
    return const [Student(id: 1, admissionNo: '1', name: 'Ali')];
  }

  @override
  Future<List<ClassOption>> getClassOptions() async => const [ClassOption(id: 1, name: 'Class 1')];

  @override
  Future<String> nextAdmissionNo() async => '12';

  @override
  Future<Student> admit(Student student) async {
    if (admitError != null) throw StudentsException(admitError!);
    if (fail) throw Exception('db');
    admittedInput = student;
    return student.withAdmissionNo('12');
  }

  @override
  Future<LeavingCertificate> getCertificateDefaults(int studentId, DateTime today) async {
    if (fail) throw Exception('db');
    return _certificate.copyWith(issueDate: () => today);
  }
}

class _FakePdf implements CertificatePdfService {
  final built = <LeavingCertificate>[];
  bool fail = false;

  @override
  Future<Uint8List> build(LeavingCertificate certificate) async {
    if (fail) throw Exception('pdf');
    built.add(certificate);
    return Uint8List.fromList([built.length]);
  }
}

void main() {
  late _FakeRepository repo;

  setUp(() => repo = _FakeRepository());

  group('AdmissionsCubit', () {
    test('load emits loading then success', () async {
      final cubit = AdmissionsCubit(repo);
      final statuses = <AdmissionsStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statuses, [AdmissionsStatus.loading, AdmissionsStatus.success]);
      expect(cubit.state.students, hasLength(1));
      await cubit.close();
    });

    test('failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = AdmissionsCubit(repo);

      await cubit.load();

      expect(cubit.state.status, AdmissionsStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });

    test('search and date range are sent to the repository and can be cleared', () async {
      final cubit = AdmissionsCubit(repo);
      await cubit.load();

      await cubit.search('ali');
      await cubit.setRange(from: DateTime(2026, 5, 1), to: DateTime(2026, 5, 31));
      expect(repo.lastQuery, 'ali');
      expect(repo.lastFrom, DateTime(2026, 5, 1));
      expect(repo.lastTo, DateTime(2026, 5, 31));
      expect(cubit.state.hasFilter, isTrue);

      await cubit.setRange();
      await cubit.search('');
      expect(repo.lastFrom, isNull);
      expect(repo.lastTo, isNull);
      expect(cubit.state.hasFilter, isFalse);
      await cubit.close();
    });
  });

  group('AdmissionFormCubit', () {
    test('load gives classes and the next number', () async {
      final cubit = AdmissionFormCubit(repo);

      await cubit.load();

      expect(cubit.state.status, AdmissionFormStatus.ready);
      expect(cubit.state.nextAdmissionNo, '12');
      expect(cubit.state.classes.single.name, 'Class 1');
      await cubit.close();
    });

    test('admit saves and returns the student with its number', () async {
      final cubit = AdmissionFormCubit(repo);
      await cubit.load();

      await cubit.admit(const Student(admissionNo: '', name: 'Ali'));

      expect(cubit.state.status, AdmissionFormStatus.saved);
      expect(cubit.state.admitted?.admissionNo, '12');
      await cubit.close();
    });

    test('a refused admission goes back to ready with the reason', () async {
      repo.admitError = 'Student name is required.';
      final cubit = AdmissionFormCubit(repo);
      await cubit.load();

      await cubit.admit(const Student(admissionNo: '', name: ''));

      expect(cubit.state.status, AdmissionFormStatus.ready);
      expect(cubit.state.errorMessage, 'Student name is required.');
      await cubit.close();
    });

    test('unexpected error shows a friendly message', () async {
      final cubit = AdmissionFormCubit(repo);
      await cubit.load();
      repo.fail = true;

      await cubit.admit(const Student(admissionNo: '', name: 'Ali'));

      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  group('CertificateCubit', () {
    final today = DateTime(2026, 7, 1);

    test('load fills defaults and draws the first PDF', () async {
      final pdf = _FakePdf();
      final cubit = CertificateCubit(repo, pdf, clock: () => today);

      await cubit.load(1);

      expect(cubit.state.status, CertificateStatus.success);
      expect(cubit.state.certificate?.issueDate, today);
      expect(cubit.state.pdfBytes, isNotNull);
      expect(pdf.built, hasLength(1));
      await cubit.close();
    });

    test('update redraws the PDF with the changed values', () async {
      final pdf = _FakePdf();
      final cubit = CertificateCubit(repo, pdf, clock: () => today);
      await cubit.load(1);

      await cubit.update(cubit.state.certificate!.copyWith(discipline: 'Excellent'));

      expect(cubit.state.certificate?.discipline, 'Excellent');
      expect(pdf.built.last.discipline, 'Excellent');
      expect(cubit.state.pdfBytes, Uint8List.fromList([2]));
      await cubit.close();
    });

    test('load failure shows a friendly message', () async {
      repo.fail = true;
      final cubit = CertificateCubit(repo, _FakePdf(), clock: () => today);

      await cubit.load(1);

      expect(cubit.state.status, CertificateStatus.failure);
      expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
      await cubit.close();
    });

    test('a PDF drawing error is reported', () async {
      final pdf = _FakePdf()..fail = true;
      final cubit = CertificateCubit(repo, pdf, clock: () => today);

      await cubit.load(1);

      expect(cubit.state.status, CertificateStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);
      await cubit.close();
    });
  });
}
