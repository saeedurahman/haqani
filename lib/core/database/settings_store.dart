import 'app_database.dart';

/// Reads and writes values in the `app_settings` table.
class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(_db.appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    final value = row?.value;
    return (value == null || value.isEmpty) ? null : value;
  }

  /// A null or empty [value] removes the setting.
  Future<void> write(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
      return;
    }
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }
}
