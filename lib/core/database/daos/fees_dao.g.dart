// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fees_dao.dart';

// ignore_for_file: type=lint
mixin _$FeesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchoolClassesTable get schoolClasses => attachedDatabase.schoolClasses;
  $FeeStructureTable get feeStructure => attachedDatabase.feeStructure;
  $StaffTable get staff => attachedDatabase.staff;
  $SectionsTable get sections => attachedDatabase.sections;
  $StudentsTable get students => attachedDatabase.students;
  $FeeVouchersTable get feeVouchers => attachedDatabase.feeVouchers;
  FeesDaoManager get managers => FeesDaoManager(this);
}

class FeesDaoManager {
  final _$FeesDaoMixin _db;
  FeesDaoManager(this._db);
  $$SchoolClassesTableTableManager get schoolClasses =>
      $$SchoolClassesTableTableManager(_db.attachedDatabase, _db.schoolClasses);
  $$FeeStructureTableTableManager get feeStructure =>
      $$FeeStructureTableTableManager(_db.attachedDatabase, _db.feeStructure);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db.attachedDatabase, _db.staff);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$FeeVouchersTableTableManager get feeVouchers =>
      $$FeeVouchersTableTableManager(_db.attachedDatabase, _db.feeVouchers);
}
