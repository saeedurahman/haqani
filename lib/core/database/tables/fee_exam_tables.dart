import 'package:drift/drift.dart';

import 'school_tables.dart';
import 'student_tables.dart';

class FeeStructure extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().unique().references(SchoolClasses, #id)();
  IntColumn get monthlyFee => integer().withDefault(const Constant(0))();
  IntColumn get annualFee => integer().withDefault(const Constant(0))();
  IntColumn get admissionFee => integer().withDefault(const Constant(0))();
}

class FeeVouchers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get receiptNo => text()();
  TextColumn get date => text()();
  IntColumn get studentId => integer().references(Students, #id)();

  /// Month the fee is for, e.g. `2026-05`.
  TextColumn get forMonth => text()();
  IntColumn get monthlyFee => integer().withDefault(const Constant(0))();
  IntColumn get annualFee => integer().withDefault(const Constant(0))();
  IntColumn get admissionFee => integer().withDefault(const Constant(0))();
  IntColumn get miscFee => integer().withDefault(const Constant(0))();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get previousDues => integer().withDefault(const Constant(0))();
  IntColumn get total => integer().withDefault(const Constant(0))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();

  /// `paid`, `partial` or `unpaid`.
  TextColumn get status => text().withDefault(const Constant('unpaid'))();
}

class Exams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get classId => integer().references(SchoolClasses, #id)();
  TextColumn get date => text().nullable()();
}

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(SchoolClasses, #id)();
  TextColumn get name => text()();
  IntColumn get totalMarks => integer().withDefault(const Constant(100))();
}

class Results extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn get obtainedMarks => integer().withDefault(const Constant(0))();
}
