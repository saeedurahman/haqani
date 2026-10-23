import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/staff_dao.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/staff_exception.dart';
import '../domain/staff_member.dart';
import '../domain/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl(AppDatabase db) : _dao = db.staffDao;

  final StaffDao _dao;

  @override
  Future<List<StaffMember>> searchStaff({String query = '', bool includeInactive = false}) async {
    final rows = await _dao.search(query: query, includeInactive: includeInactive);
    return [for (final r in rows) _toMember(r)];
  }

  @override
  Future<StaffMember?> getStaff(int id) async {
    final row = await _dao.byId(id);
    return row == null ? null : _toMember(row);
  }

  @override
  Future<int> saveStaff(StaffMember member) async {
    final name = member.name.trim();
    if (name.isEmpty) throw const StaffException('Name is required.');
    if (member.salary < 0) throw const StaffException('Salary cannot be less than 0.');

    final data = StaffCompanion(
      name: Value(name),
      fatherName: Value(member.fatherName.trim()),
      designation: Value(member.designation.trim()),
      phone: Value(member.phone.trim()),
      cnic: Value(member.cnic.trim()),
      joiningDate: Value(member.joiningDate == null ? null : AppDateUtils.toIso(member.joiningDate!)),
      salary: Value(member.salary),
      address: Value(member.address.trim()),
    );
    if (member.id == 0) return _dao.insertStaff(data);
    if (await _dao.byId(member.id) == null) throw const StaffException('This person was not found.');
    await _dao.updateStaff(member.id, data);
    return member.id;
  }

  @override
  Future<void> setActive(int id, {required bool active}) {
    return _dao.updateStaff(id, StaffCompanion(isActive: Value(active)));
  }

  StaffMember _toMember(StaffData r) {
    return StaffMember(
      id: r.id,
      name: r.name,
      fatherName: r.fatherName,
      designation: r.designation,
      phone: r.phone,
      cnic: r.cnic,
      joiningDate: AppDateUtils.tryParseIso(r.joiningDate),
      salary: r.salary,
      address: r.address,
      isActive: r.isActive,
    );
  }
}
