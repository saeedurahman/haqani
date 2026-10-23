import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart' hide Student, FeeVoucher;
import '../../../core/database/app_database.dart' as d show Student, FeeVoucher;
import '../../../core/database/daos/fees_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../students/domain/student_extras.dart';
import '../domain/fee_models.dart';
import '../domain/fees_repository.dart';

class FeesRepositoryImpl implements FeesRepository {
  FeesRepositoryImpl(this._db, {DateTime Function()? clock})
      : _dao = _db.feesDao,
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final FeesDao _dao;
  final DateTime Function() _clock;

  @override
  Future<List<ClassOption>> getClassOptions() async {
    final classes = await _dao.classes();
    final sections = await _dao.allSections();
    return [
      for (final c in classes)
        ClassOption(
          id: c.id,
          name: c.name,
          sections: [
            for (final s in sections.where((s) => s.classId == c.id))
              SectionOption(id: s.id, name: s.name),
          ],
        ),
    ];
  }

  @override
  Future<List<ClassFee>> getFeeStructures() async {
    final classes = await _dao.classes();
    final structures = {for (final s in await _dao.structures()) s.classId: s};
    return [
      for (final c in classes)
        ClassFee(
          classId: c.id,
          className: c.name,
          monthlyFee: structures[c.id]?.monthlyFee ?? 0,
          annualFee: structures[c.id]?.annualFee ?? 0,
          admissionFee: structures[c.id]?.admissionFee ?? 0,
        ),
    ];
  }

  @override
  Future<void> saveFeeStructure(int classId, int monthly, int annual, int admission) {
    if (monthly < 0 || annual < 0 || admission < 0) {
      throw const FeesException('Fees cannot be less than 0.');
    }
    return _dao.saveStructure(classId, monthly, annual, admission);
  }

  @override
  Future<List<FeeStudent>> findStudents(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final rows = await _db.studentsDao.search(query: q);
    final labels = await _labels();
    return [
      for (final r in rows.take(30)) _feeStudent(r.student, labels),
    ];
  }

  @override
  Future<List<FeeStudent>> getFamily(int studentId) async {
    final row = await _db.studentsDao.byId(studentId);
    if (row == null) throw const FeesException('This student was not found.');
    final siblings = await _dao.siblingsOf(row.student);
    final labels = await _labels();
    return [
      _feeStudent(row.student, labels),
      for (final s in siblings) _feeStudent(s, labels),
    ];
  }

  @override
  Future<FeeVoucher?> getOutstanding(int studentId) async {
    final vouchers = await _dao.vouchersOfStudent(studentId);
    if (vouchers.isEmpty || vouchers.first.total - vouchers.first.paidAmount <= 0) return null;
    return (await _toVouchers([vouchers.first])).single;
  }

  @override
  Future<List<FeeVoucher>> getHistory(int studentId) async {
    return _toVouchers(await _dao.vouchersOfStudent(studentId));
  }

  @override
  Future<GenerationResult> generateVouchers({
    int? classId,
    int? sectionId,
    int? studentId,
    required String month,
    bool includeAnnualFee = false,
  }) async {
    final List<d.Student> students;
    final int feeClassId;
    if (studentId != null) {
      students = await _dao.studentsByIds([studentId]);
      final cls = students.firstOrNull?.classId;
      if (cls == null) throw const FeesException('This student is not in a class yet.');
      feeClassId = cls;
    } else {
      if (classId == null) throw const FeesException('Choose a class first.');
      feeClassId = classId;
      students = await _dao.activeStudents(classId, sectionId);
    }

    final structure = await _dao.structureOf(feeClassId);
    if (structure == null || structure.monthlyFee <= 0) {
      final name = (await _labels()).classes[feeClassId] ?? 'this class';
      throw FeesException('Set the monthly fee for $name first (Fee Structure tab).');
    }

    final today = AppDateUtils.toIso(_clock());
    return _db.transaction(() async {
      final latestMonth = await _dao.latestMonthByStudent([for (final s in students) s.id]);
      var created = 0;
      var skipped = 0;
      for (final s in students) {
        final latest = latestMonth[s.id];
        if (latest != null && latest.compareTo(month) >= 0) {
          skipped++;
          continue;
        }
        final history = await _dao.vouchersOfStudent(s.id);
        final owed = history.isEmpty ? 0 : history.first.total - history.first.paidAmount;
        final previousDues = owed > 0 ? owed : 0;
        final admissionMonth = s.admissionDate?.substring(0, 7);
        final admission = admissionMonth == month ? structure.admissionFee : 0;
        final annual = includeAnnualFee ? structure.annualFee : 0;
        final total = structure.monthlyFee + annual + admission + previousDues;
        await _dao.insertVoucher(FeeVouchersCompanion.insert(
          receiptNo: '',
          date: today,
          studentId: s.id,
          forMonth: month,
          monthlyFee: Value(structure.monthlyFee),
          annualFee: Value(annual),
          admissionFee: Value(admission),
          previousDues: Value(previousDues),
          total: Value(total),
          status: Value(FeeStatus.of(total, 0)),
        ));
        created++;
      }
      return GenerationResult(created: created, skipped: skipped);
    });
  }

  @override
  Future<List<FeeVoucher>> getVouchers({
    required String month,
    required int classId,
    int? sectionId,
  }) async {
    final students = await _dao.activeStudents(classId, sectionId);
    final vouchers = await _dao.vouchersOfMonth(month, [for (final s in students) s.id]);
    final converted = await _toVouchers(vouchers);
    converted.sort((a, b) => a.student.name.compareTo(b.student.name));
    return converted;
  }

  @override
  Future<FeeReceipt> collect(List<PaymentRequest> payments, DateTime date) async {
    final real = payments.where((p) => p.amount > 0).toList();
    if (real.isEmpty) throw const FeesException('Enter an amount to receive.');

    final iso = AppDateUtils.toIso(date);
    final received = <int, int>{};
    late final String receiptNo;
    final ids = await _db.transaction(() async {
      receiptNo = await _nextReceiptNo();
      for (final p in real) {
        final v = await _dao.voucherById(p.voucherId);
        if (v == null) throw const FeesException('A voucher was not found.');
        if (p.miscFee < 0 || p.discount < 0) {
          throw const FeesException('Misc fee and discount cannot be less than 0.');
        }
        final total = v.monthlyFee + v.annualFee + v.admissionFee + v.previousDues +
            p.miscFee - p.discount;
        if (total < v.paidAmount) {
          throw const FeesException('The discount is more than the fee.');
        }
        if (p.amount > total - v.paidAmount) {
          throw const FeesException('The amount is more than the balance.');
        }
        final paid = v.paidAmount + p.amount;
        await _dao.updateVoucher(
          v.id,
          FeeVouchersCompanion(
            miscFee: Value(p.miscFee),
            discount: Value(p.discount),
            total: Value(total),
            paidAmount: Value(paid),
            status: Value(FeeStatus.of(total, paid)),
            receiptNo: Value(receiptNo),
            date: Value(iso),
          ),
        );
        received[v.id] = p.amount;
      }
      return received.keys.toList();
    });

    final vouchers = <d.FeeVoucher>[
      for (final id in ids) (await _dao.voucherById(id))!,
    ];
    return _buildReceipt(receiptNo, vouchers, received);
  }

  @override
  Future<FeeReceipt?> getReceipt(String receiptNo) async {
    final vouchers = await _dao.vouchersOfReceipt(receiptNo);
    if (vouchers.isEmpty) return null;
    return _buildReceipt(receiptNo, vouchers, const {});
  }

  Future<String> _nextReceiptNo() async {
    var biggest = 0;
    for (final no in await _dao.allReceiptNos()) {
      final n = int.tryParse(no);
      if (n != null && n > biggest) biggest = n;
    }
    return '${biggest + 1}';
  }

  Future<FeeReceipt> _buildReceipt(
    String receiptNo,
    List<d.FeeVoucher> vouchers,
    Map<int, int> receivedNow,
  ) async {
    final converted = await _toVouchers(vouchers);
    return FeeReceipt(
      receiptNo: receiptNo,
      date: converted.first.date,
      schoolName: await _setting(AppConstants.settingSchoolName) ?? AppStrings.defaultSchoolName,
      schoolAddress: await _setting(AppConstants.settingSchoolAddress) ?? '',
      lines: [
        for (final v in converted) ReceiptLine(voucher: v, receivedNow: receivedNow[v.id]),
      ],
    );
  }

  Future<String?> _setting(String key) async {
    final row = await (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    final value = row?.value;
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<_Labels> _labels() async {
    return _Labels(
      classes: {for (final c in await _dao.classes()) c.id: c.name},
      sections: {for (final s in await _dao.allSections()) s.id: s.name},
    );
  }

  FeeStudent _feeStudent(d.Student s, _Labels labels) {
    final className = labels.classes[s.classId];
    final sectionName = labels.sections[s.sectionId];
    return FeeStudent(
      id: s.id,
      name: s.name,
      admissionNo: s.admissionNo,
      registrationNo: s.registrationNo,
      fatherName: s.fatherName,
      gender: s.gender,
      classLabel: className == null
          ? 'No class'
          : sectionName == null
              ? className
              : '$className - $sectionName',
    );
  }

  Future<List<FeeVoucher>> _toVouchers(List<d.FeeVoucher> vouchers) async {
    if (vouchers.isEmpty) return [];
    final ids = {for (final v in vouchers) v.studentId}.toList();
    final labels = await _labels();
    final students = {for (final s in await _dao.studentsByIds(ids)) s.id: s};
    final latest = await _dao.latestMonthByStudent(ids);
    return [
      for (final v in vouchers)
        FeeVoucher(
          id: v.id,
          receiptNo: v.receiptNo,
          date: DateTime.parse(v.date),
          student: _feeStudent(students[v.studentId]!, labels),
          forMonth: v.forMonth,
          monthlyFee: v.monthlyFee,
          annualFee: v.annualFee,
          admissionFee: v.admissionFee,
          miscFee: v.miscFee,
          discount: v.discount,
          previousDues: v.previousDues,
          total: v.total,
          paidAmount: v.paidAmount,
          status: v.status,
          carriedForward:
              v.total - v.paidAmount > 0 && (latest[v.studentId] ?? v.forMonth) != v.forMonth,
        ),
    ];
  }
}

class _Labels {
  const _Labels({required this.classes, required this.sections});

  final Map<int, String> classes;
  final Map<int, String> sections;
}
