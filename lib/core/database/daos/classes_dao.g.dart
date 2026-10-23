// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_dao.dart';

// ignore_for_file: type=lint
mixin _$ClassesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchoolClassesTable get schoolClasses => attachedDatabase.schoolClasses;
  $StaffTable get staff => attachedDatabase.staff;
  $SectionsTable get sections => attachedDatabase.sections;
  $StudentsTable get students => attachedDatabase.students;
  $ExamsTable get exams => attachedDatabase.exams;
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $FeeStructureTable get feeStructure => attachedDatabase.feeStructure;
  ClassesDaoManager get managers => ClassesDaoManager(this);
}

class ClassesDaoManager {
  final _$ClassesDaoMixin _db;
  ClassesDaoManager(this._db);
  $$SchoolClassesTableTableManager get schoolClasses =>
      $$SchoolClassesTableTableManager(_db.attachedDatabase, _db.schoolClasses);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db.attachedDatabase, _db.staff);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db.attachedDatabase, _db.exams);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$FeeStructureTableTableManager get feeStructure =>
      $$FeeStructureTableTableManager(_db.attachedDatabase, _db.feeStructure);
}
