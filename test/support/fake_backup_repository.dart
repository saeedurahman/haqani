import 'package:haqani/core/services/app_restarter.dart';
import 'package:haqani/features/backup/domain/backup_models.dart';
import 'package:haqani/features/backup/domain/backup_repository.dart';

class FakeBackupRepository implements BackupRepository {
  BackupSettings settings = const BackupSettings(
    folder: r'C:\Backups',
    isDefaultFolder: true,
    driveConfigured: true,
  );
  List<BackupFile> local = [];
  List<BackupFile> drive = [];
  DriveUploadStatus driveStatus = DriveUploadStatus.notConnected;
  String? driveMessage;
  String? error;
  bool failUnexpected = false;
  BackupFile? restored;
  String? savedFolder = 'unset';
  var backups = 0;
  var disconnects = 0;

  void _check() {
    if (failUnexpected) throw Exception('boom');
    if (error != null) throw BackupException(error!);
  }

  @override
  Future<BackupSettings> getSettings() async {
    if (failUnexpected) throw Exception('boom');
    return settings;
  }

  @override
  Future<void> setBackupFolder(String? path) async {
    _check();
    savedFolder = path;
    settings = BackupSettings(
      folder: path ?? r'C:\Backups',
      isDefaultFolder: path == null,
      lastBackup: settings.lastBackup,
      driveConfigured: settings.driveConfigured,
      driveEmail: settings.driveEmail,
      drivePending: settings.drivePending,
    );
  }

  @override
  Future<List<BackupFile>> listLocalBackups() async => local;

  @override
  Future<List<BackupFile>> listDriveBackups() async {
    _check();
    return drive;
  }

  @override
  Future<BackupResult> backupNow() async {
    _check();
    backups++;
    final file = BackupFile(
      name: 'school_backup_2026-05-12_09-30.zip',
      size: 2048,
      createdAt: DateTime(2026, 5, 12, 9, 30),
      path: r'C:\Backups\school_backup_2026-05-12_09-30.zip',
    );
    local = [file, ...local];
    settings = BackupSettings(
      folder: settings.folder,
      isDefaultFolder: settings.isDefaultFolder,
      lastBackup: file.createdAt,
      driveConfigured: settings.driveConfigured,
      driveEmail: settings.driveEmail,
    );
    return BackupResult(file: file, drive: driveStatus, driveMessage: driveMessage);
  }

  @override
  Future<void> runAutoBackup() async {}

  @override
  Future<String> connectDrive() async {
    _check();
    settings = BackupSettings(
      folder: settings.folder,
      isDefaultFolder: settings.isDefaultFolder,
      driveConfigured: true,
      driveEmail: 'school@example.com',
    );
    return 'school@example.com';
  }

  @override
  Future<void> disconnectDrive() async {
    disconnects++;
    settings = BackupSettings(
      folder: settings.folder,
      isDefaultFolder: settings.isDefaultFolder,
      lastBackup: settings.lastBackup,
      driveConfigured: true,
    );
  }

  @override
  Future<void> restore(BackupFile backup) async {
    _check();
    restored = backup;
  }
}

class FakeRestarter implements AppRestarter {
  var restarts = 0;

  @override
  Future<void> restart() async => restarts++;
}
