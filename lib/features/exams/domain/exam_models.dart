import 'package:equatable/equatable.dart';

/// Thrown with a message that is safe to show to the user.
class ExamsException implements Exception {
  const ExamsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Exam extends Equatable {
  const Exam({
    this.id = 0,
    required this.name,
    required this.classId,
    this.className = '',
    this.date,
    this.studentsWithMarks = 0,
  });

  /// 0 means not saved yet.
  final int id;

  /// Example: Annual 2026.
  final String name;
  final int classId;
  final String className;
  final DateTime? date;

  /// How many students already have marks. Read only.
  final int studentsWithMarks;

  @override
  List<Object?> get props => [id, name, classId, className, date, studentsWithMarks];
}

class Subject extends Equatable {
  const Subject({
    this.id = 0,
    required this.classId,
    required this.name,
    this.totalMarks = 100,
  });

  final int id;
  final int classId;
  final String name;
  final int totalMarks;

  @override
  List<Object?> get props => [id, classId, name, totalMarks];
}

/// A student in an exam, with the marks entered so far.
class StudentMarks extends Equatable {
  const StudentMarks({
    required this.studentId,
    required this.name,
    required this.admissionNo,
    this.fatherName = '',
    this.gender = 'male',
    this.sectionName,
    this.marks = const {},
  });

  final int studentId;
  final String name;
  final String admissionNo;
  final String fatherName;
  final String gender;
  final String? sectionName;

  /// Subject id -> marks. A subject that is missing has no marks yet.
  final Map<int, int> marks;

  @override
  List<Object?> get props =>
      [studentId, name, admissionNo, fatherName, gender, sectionName, marks];
}

/// Everything needed to enter marks and work out results for one exam.
class MarksSheet extends Equatable {
  const MarksSheet({required this.exam, required this.subjects, required this.students});

  final Exam exam;
  final List<Subject> subjects;
  final List<StudentMarks> students;

  @override
  List<Object?> get props => [exam, subjects, students];
}

/// One mark to save. A null [marks] clears the mark.
class MarkEntry extends Equatable {
  const MarkEntry({required this.studentId, required this.subjectId, this.marks});

  final int studentId;
  final int subjectId;
  final int? marks;

  @override
  List<Object?> get props => [studentId, subjectId, marks];
}

class SchoolInfo extends Equatable {
  const SchoolInfo({required this.name, this.address = '', this.phone = '', this.logoPath});

  final String name;
  final String address;
  final String phone;

  /// Full path of the school logo, or null.
  final String? logoPath;

  @override
  List<Object?> get props => [name, address, phone, logoPath];
}
