import 'package:drift/drift.dart';

import 'school_tables.dart';

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get admissionNo => text().unique()();
  TextColumn get registrationNo => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get fatherName => text().withDefault(const Constant(''))();
  TextColumn get fatherCnic => text().withDefault(const Constant(''))();
  TextColumn get dob => text().nullable()();
  TextColumn get gender => text().withDefault(const Constant('male'))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get whatsappNo => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get fatherProfession => text().withDefault(const Constant(''))();
  TextColumn get fatherEducation => text().withDefault(const Constant(''))();
  TextColumn get previousSchool => text().withDefault(const Constant(''))();
  TextColumn get previousClass => text().withDefault(const Constant(''))();
  IntColumn get classId => integer().nullable().references(SchoolClasses, #id)();
  IntColumn get sectionId => integer().nullable().references(Sections, #id)();
  TextColumn get admissionDate => text().nullable()();

  /// `active` or `left`.
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get leavingDate => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class StudentDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
}

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get date => text()();

  /// `present`, `absent` or `leave`.
  TextColumn get status => text()();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {studentId, date},
      ];
}
