import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/fee_exam_tables.dart';
import '../tables/school_tables.dart';
import '../tables/student_tables.dart';

part 'fees_dao.g.dart';

@DriftAccessor(tables: [FeeStructure, FeeVouchers, FeePayments, Students, SchoolClasses, Sections])
class FeesDao extends DatabaseAccessor<AppDatabase> with _$FeesDaoMixin {
  FeesDao(super.db);

  Future<List<SchoolClassesData>> classes() {
    return (select(schoolClasses)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<List<Section>> allSections() {
    return (select(sections)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<List<FeeStructureData>> structures() => select(feeStructure).get();

  Future<FeeStructureData?> structureOf(int classId) {
    return (select(feeStructure)..where((t) => t.classId.equals(classId))).getSingleOrNull();
  }

  Future<void> saveStructure(int classId, int monthly, int annual, int admission) {
    return into(feeStructure).insert(
      FeeStructureCompanion.insert(
        classId: classId,
        monthlyFee: Value(monthly),
        annualFee: Value(annual),
        admissionFee: Value(admission),
      ),
      onConflict: DoUpdate(
        (old) => FeeStructureCompanion(
          monthlyFee: Value(monthly),
          annualFee: Value(annual),
          admissionFee: Value(admission),
        ),
        target: [feeStructure.classId],
      ),
    );
  }

  /// Active students of a class (and section), sorted by name.
  Future<List<Student>> activeStudents(int classId, int? sectionId) {
    return (select(students)
          ..where((t) {
            Expression<bool> w = t.status.equals('active') & t.classId.equals(classId);
            if (sectionId != null) w = w & t.sectionId.equals(sectionId);
            return w;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.name), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Active students with the same father (same CNIC, or same name and phone).
  Future<List<Student>> siblingsOf(Student student) {
    return (select(students)
          ..where((t) {
            Expression<bool> same = const Constant(false);
            if (student.fatherCnic.isNotEmpty) {
              same = same | t.fatherCnic.equals(student.fatherCnic);
            }
            if (student.fatherName.isNotEmpty && student.phone.isNotEmpty) {
              same = same |
                  (t.fatherName.lower().equals(student.fatherName.toLowerCase()) &
                      t.phone.equals(student.phone));
            }
            return t.status.equals('active') & t.id.equals(student.id).not() & same;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<FeeVoucher?> voucherById(int id) {
    return (select(feeVouchers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Newest month first.
  Future<List<FeeVoucher>> vouchersOfStudent(int studentId) {
    return (select(feeVouchers)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.forMonth),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<List<FeeVoucher>> vouchersOfMonth(String month, List<int> studentIds) {
    if (studentIds.isEmpty) return Future.value(const []);
    return (select(feeVouchers)
          ..where((t) => t.forMonth.equals(month) & t.studentId.isIn(studentIds)))
        .get();
  }

  /// Payments of the given vouchers, oldest first.
  Future<List<FeePaymentRow>> paymentsOfVouchers(List<int> voucherIds) {
    if (voucherIds.isEmpty) return Future.value(const []);
    return (select(feePayments)
          ..where((t) => t.voucherId.isIn(voucherIds))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Payments that share one receipt number.
  Future<List<FeePaymentRow>> paymentsOfReceipt(String receiptNo) {
    return (select(feePayments)
          ..where((t) => t.receiptNo.equals(receiptNo))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<List<String>> allReceiptNos() async {
    final query = selectOnly(feePayments, distinct: true)..addColumns([feePayments.receiptNo]);
    return [for (final r in await query.get()) r.read(feePayments.receiptNo)!];
  }

  Future<void> insertPayment(FeePaymentsCompanion data) => into(feePayments).insert(data);

  Future<void> insertVoucher(FeeVouchersCompanion data) => into(feeVouchers).insert(data);

  Future<void> updateVoucher(int id, FeeVouchersCompanion data) {
    return (update(feeVouchers)..where((t) => t.id.equals(id))).write(data);
  }

  Future<List<Student>> studentsByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(students)..where((t) => t.id.isIn(ids))).get();
  }

  /// Newest voucher month of each given student (`yyyy-MM`).
  Future<Map<int, String>> latestMonthByStudent(List<int> ids) async {
    if (ids.isEmpty) return {};
    final latest = feeVouchers.forMonth.max();
    final query = selectOnly(feeVouchers)
      ..addColumns([feeVouchers.studentId, latest])
      ..where(feeVouchers.studentId.isIn(ids))
      ..groupBy([feeVouchers.studentId]);
    return {
      for (final r in await query.get()) r.read(feeVouchers.studentId)!: r.read(latest)!,
    };
  }

  /// Every voucher that still has a balance.
  Future<List<FeeVoucher>> vouchersWithBalance() {
    return (select(feeVouchers)
          ..where((t) => (t.total - t.paidAmount).isBiggerThanValue(0)))
        .get();
  }
}
