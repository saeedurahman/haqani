import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/school_tables.dart';

part 'staff_dao.g.dart';

@DriftAccessor(tables: [Staff])
class StaffDao extends DatabaseAccessor<AppDatabase> with _$StaffDaoMixin {
  StaffDao(super.db);

  /// Matches name, father name, designation or phone. Sorted by name.
  Future<List<StaffData>> search({String query = '', bool includeInactive = false}) {
    final q = query.trim();
    return (select(staff)
          ..where((t) {
            Expression<bool> w = const Constant(true);
            if (!includeInactive) w = w & t.isActive.equals(true);
            if (q.isNotEmpty) {
              final pattern = '%$q%';
              w = w &
                  (t.name.like(pattern) |
                      t.fatherName.like(pattern) |
                      t.designation.like(pattern) |
                      t.phone.like(pattern));
            }
            return w;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.name), (t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<StaffData?> byId(int id) {
    return (select(staff)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertStaff(StaffCompanion data) => into(staff).insert(data);

  Future<void> updateStaff(int id, StaffCompanion data) {
    return (update(staff)..where((t) => t.id.equals(id))).write(data);
  }
}
