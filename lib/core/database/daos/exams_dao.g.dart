// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exams_dao.dart';

// ignore_for_file: type=lint
mixin _$ExamsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchoolClassesTable get schoolClasses => attachedDatabase.schoolClasses;
  $ExamsTable get exams => attachedDatabase.exams;
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $StaffTable get staff => attachedDatabase.staff;
  $SectionsTable get sections => attachedDatabase.sections;
  $StudentsTable get students => attachedDatabase.students;
  $ResultsTable get results => attachedDatabase.results;
  ExamsDaoManager get managers => ExamsDaoManager(this);
}

class ExamsDaoManager {
  final _$ExamsDaoMixin _db;
  ExamsDaoManager(this._db);
  $$SchoolClassesTableTableManager get schoolClasses =>
      $$SchoolClassesTableTableManager(_db.attachedDatabase, _db.schoolClasses);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db.attachedDatabase, _db.exams);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db.attachedDatabase, _db.staff);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$ResultsTableTableManager get results =>
      $$ResultsTableTableManager(_db.attachedDatabase, _db.results);
}
