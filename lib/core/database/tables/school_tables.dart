import 'package:drift/drift.dart';

class SchoolClasses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(SchoolClasses, #id)();
  TextColumn get name => text()();
  IntColumn get classTeacherId => integer().nullable().references(Staff, #id)();
}

class Staff extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get fatherName => text().withDefault(const Constant(''))();
  TextColumn get designation => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get cnic => text().withDefault(const Constant(''))();
  TextColumn get joiningDate => text().nullable()();
  IntColumn get salary => integer().withDefault(const Constant(0))();
  TextColumn get address => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
