import 'package:equatable/equatable.dart';

class SchoolSection extends Equatable {
  const SchoolSection({
    required this.id,
    required this.classId,
    required this.name,
    this.classTeacherId,
    this.classTeacherName,
    this.studentCount = 0,
  });

  final int id;
  final int classId;
  final String name;
  final int? classTeacherId;
  final String? classTeacherName;
  final int studentCount;

  @override
  List<Object?> get props => [
    id,
    classId,
    name,
    classTeacherId,
    classTeacherName,
    studentCount,
  ];
}

class SchoolClass extends Equatable {
  const SchoolClass({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.sections = const [],
    this.studentCount = 0,
  });

  final int id;
  final String name;
  final int sortOrder;
  final List<SchoolSection> sections;
  final int studentCount;

  @override
  List<Object?> get props => [id, name, sortOrder, sections, studentCount];
}

/// A teacher that can be picked as class teacher.
class TeacherOption extends Equatable {
  const TeacherOption({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
