import 'backup_models.dart';

/// Methods throw [BackupException] when something cannot be done.
abstract class BackupRepository {
  Future<BackupSettings> getSettings();

  /// Saves the folder where backups are kept. Pass null to use the app folder.
  Future<void> setBackupFolder(String? path);

  /// Backups in the backup folder, newest first.
  Future<List<BackupFile>> listLocalBackups();

  /// Backups on Google Drive, newest first.
  Future<List<BackupFile>> listDriveBackups();

  /// Makes a zip (database and documents) in the backup folder, keeps only
  /// the newest 10, and uploads to Google Drive when it is connected.
  Future<BackupResult> backupNow();

  /// Once a day, when the app starts: [backupNow] if there is no backup today,
  /// and uploads an old backup that is waiting for Drive. Never throws.
  Future<void> runAutoBackup();

  /// Opens the browser to connect a Google account. Returns the email.
  Future<String> connectDrive();

  Future<void> disconnectDrive();

  /// Replaces all data with the backup. A safety copy of the current data is
  /// made first. The database is closed afterwards, so the app must restart.
  Future<void> restore(BackupFile backup);
}
