import '../../students/domain/student_extras.dart';
import 'fee_models.dart';

/// Methods throw [FeesException] when a rule blocks the change.
abstract class FeesRepository {
  Future<List<ClassOption>> getClassOptions();

  /// Every class, with zeros where no fee is set yet.
  Future<List<ClassFee>> getFeeStructures();
  Future<void> saveFeeStructure(int classId, int monthly, int annual, int admission);

  /// Active students matching name, father name, admission or registration no.
  Future<List<FeeStudent>> findStudents(String query);

  /// The student first, then active brothers and sisters.
  Future<List<FeeStudent>> getFamily(int studentId);

  /// The voucher that holds what the student still owes (the newest one with
  /// a balance), or null if nothing is due.
  Future<FeeVoucher?> getOutstanding(int studentId);

  /// All vouchers of a student, newest month first.
  Future<List<FeeVoucher>> getHistory(int studentId);

  /// Makes vouchers for [month] (`yyyy-MM`). Pass [studentId] for one student,
  /// otherwise the whole class (and section). Unpaid money of earlier months
  /// is added as previous dues.
  Future<GenerationResult> generateVouchers({
    int? classId,
    int? sectionId,
    int? studentId,
    required String month,
    bool includeAnnualFee = false,
  });

  /// Vouchers of one month for a class (and section), newest first by name.
  Future<List<FeeVoucher>> getVouchers({
    required String month,
    required int classId,
    int? sectionId,
  });

  /// Active students who still owe fee, biggest balance first.
  /// Pass [classId] for one class only.
  Future<List<Defaulter>> getDefaulters({int? classId});

  /// Takes the payments and gives them one new receipt number.
  Future<FeeReceipt> collect(List<PaymentRequest> payments, DateTime date);

  /// Rebuilds a receipt from its number, or null if there is none.
  Future<FeeReceipt?> getReceipt(String receiptNo);
}
