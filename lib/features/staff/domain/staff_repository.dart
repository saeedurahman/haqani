import 'staff_member.dart';

/// Methods throw [StaffException] when a rule blocks the change.
abstract class StaffRepository {
  /// Matches name, father name, designation or phone, sorted by name.
  Future<List<StaffMember>> searchStaff({String query = '', bool includeInactive = false});

  Future<StaffMember?> getStaff(int id);

  /// Adds when `member.id == 0`, otherwise updates. Returns the saved id.
  Future<int> saveStaff(StaffMember member);

  /// Soft delete: the person is hidden but records (class teacher) are kept.
  Future<void> setActive(int id, {required bool active});
}
