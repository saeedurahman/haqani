// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'students_dao.dart';

// ignore_for_file: type=lint
mixin _$StudentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchoolClassesTable get schoolClasses => attachedDatabase.schoolClasses;
  $StaffTable get staff => attachedDatabase.staff;
  $SectionsTable get sections => attachedDatabase.sections;
  $StudentsTable get students => attachedDatabase.students;
  $StudentDocumentsTable get studentDocuments =>
      attachedDatabase.studentDocuments;
  $AttendanceTable get attendance => attachedDatabase.attendance;
  $FeeVouchersTable get feeVouchers => attachedDatabase.feeVouchers;
  $FeePaymentsTable get feePayments => attachedDatabase.feePayments;
  $ExamsTable get exams => attachedDatabase.exams;
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $ResultsTable get results => attachedDatabase.results;
  StudentsDaoManager get managers => StudentsDaoManager(this);
}

class StudentsDaoManager {
  final _$StudentsDaoMixin _db;
  StudentsDaoManager(this._db);
  $$SchoolClassesTableTableManager get schoolClasses =>
      $$SchoolClassesTableTableManager(_db.attachedDatabase, _db.schoolClasses);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db.attachedDatabase, _db.staff);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$StudentDocumentsTableTableManager get studentDocuments =>
      $$StudentDocumentsTableTableManager(
        _db.attachedDatabase,
        _db.studentDocuments,
      );
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db.attachedDatabase, _db.attendance);
  $$FeeVouchersTableTableManager get feeVouchers =>
      $$FeeVouchersTableTableManager(_db.attachedDatabase, _db.feeVouchers);
  $$FeePaymentsTableTableManager get feePayments =>
      $$FeePaymentsTableTableManager(_db.attachedDatabase, _db.feePayments);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db.attachedDatabase, _db.exams);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$ResultsTableTableManager get results =>
      $$ResultsTableTableManager(_db.attachedDatabase, _db.results);
}
