import 'package:equatable/equatable.dart';

class StudentDocumentItem extends Equatable {
  const StudentDocumentItem({
    required this.id,
    required this.title,
    required this.filePath,
  });

  final int id;
  final String title;
  final String filePath;

  @override
  List<Object?> get props => [id, title, filePath];
}

class SectionOption extends Equatable {
  const SectionOption({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class ClassOption extends Equatable {
  const ClassOption({
    required this.id,
    required this.name,
    this.sections = const [],
  });

  final int id;
  final String name;
  final List<SectionOption> sections;

  /// Same class without its sections, for screens that only need the class.
  ClassOption withoutSections() => ClassOption(id: id, name: name);

  @override
  List<Object?> get props => [id, name, sections];
}
