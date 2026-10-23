import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/app_paths.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/backup_models.dart';
import '../domain/backup_repository.dart';
import '../domain/google_drive_service.dart';
import 'backup_file_service.dart';
import 'settings_store.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl({
    required this._db,
    required this._paths,
    required this._files,
    required this._drive,
    required this._settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final AppPaths _paths;
  final BackupFileService _files;
  final GoogleDriveService _drive;
  final SettingsStore _settings;
  final DateTime Function() _clock;

  Future<Directory> _backupDir() async {
    final chosen = await _settings.read(AppConstants.settingBackupFolder);
    return chosen == null ? _paths.defaultBackupDir() : Directory(chosen);
  }

  @override
  Future<BackupSettings> getSettings() async {
    final chosen = await _settings.read(AppConstants.settingBackupFolder);
    return BackupSettings(
      folder: (await _backupDir()).path,
      isDefaultFolder: chosen == null,
      lastBackup: AppDateUtils.tryParseIso(await _settings.read(AppConstants.settingLastBackup)),
      driveConfigured: _drive.isConfigured,
      driveEmail: await _drive.connectedEmail(),
      drivePending: await _settings.read(AppConstants.settingDrivePending) == '1',
    );
  }

  @override
  Future<void> setBackupFolder(String? path) async {
    if (path != null) {
      try {
        final dir = Directory(path);
        await dir.create(recursive: true);
        // Make sure files can really be written there.
        final test = File(p.join(path, '.write_test'));
        await test.writeAsString('ok');
        await test.delete();
      } catch (_) {
        throw const BackupException(
          'The backup cannot be saved in this folder. Please choose another folder.',
        );
      }
    }
    await _settings.write(AppConstants.settingBackupFolder, path);
  }

  @override
  Future<List<BackupFile>> listLocalBackups() async => _files.listBackups(await _backupDir());

  @override
  Future<List<BackupFile>> listDriveBackups() async {
    try {
      return await _drive.list();
    } on DriveOfflineException {
      throw const BackupException(_offlineText);
    }
  }

  static const _offlineText =
      'No internet connection. Connect to the internet and try again.';

  @override
  Future<BackupResult> backupNow() async {
    final now = _clock();
    final dir = await _backupDir();
    final File zip;
    try {
      zip = await _files.createBackup(_db, dir, now);
      await _files.prune(dir, keep: AppConstants.keepLocalBackups);
    } on FileSystemException {
      throw const BackupException(
        'The backup could not be saved. Check that the backup folder exists and has free space.',
      );
    }
    await _settings.write(AppConstants.settingLastBackup, now.toIso8601String());
    final stat = await zip.stat();
    final file = BackupFile(
      name: p.basename(zip.path),
      size: stat.size,
      createdAt: now,
      path: zip.path,
    );

    if (await _drive.connectedEmail() == null) {
      return BackupResult(file: file, drive: DriveUploadStatus.notConnected);
    }
    return _uploadToDrive(file, zip);
  }

  Future<BackupResult> _uploadToDrive(BackupFile file, File zip) async {
    try {
      await _drive.upload(zip);
      await _settings.write(AppConstants.settingDrivePending, null);
      return BackupResult(file: file, drive: DriveUploadStatus.uploaded);
    } on DriveOfflineException {
      await _settings.write(AppConstants.settingDrivePending, '1');
      return BackupResult(
        file: file,
        drive: DriveUploadStatus.offline,
        driveMessage: 'There is no internet, so the backup was not uploaded to Google Drive. '
            'It is saved on this computer and will be uploaded later.',
      );
    } on BackupException catch (e) {
      await _settings.write(AppConstants.settingDrivePending, '1');
      return BackupResult(file: file, drive: DriveUploadStatus.failed, driveMessage: e.message);
    } catch (_) {
      await _settings.write(AppConstants.settingDrivePending, '1');
      return BackupResult(
        file: file,
        drive: DriveUploadStatus.failed,
        driveMessage: 'The backup could not be uploaded to Google Drive. It is saved on this computer.',
      );
    }
  }

  @override
  Future<void> runAutoBackup() async {
    try {
      final now = _clock();
      final last = AppDateUtils.tryParseIso(await _settings.read(AppConstants.settingLastBackup));
      final doneToday = last != null && AppDateUtils.toIso(last) == AppDateUtils.toIso(now);
      if (!doneToday) {
        await backupNow();
        return;
      }
      // Today's backup exists, but an earlier upload may still be waiting.
      if (await _settings.read(AppConstants.settingDrivePending) == '1' &&
          await _drive.connectedEmail() != null) {
        final newest = (await listLocalBackups()).firstOrNull;
        if (newest != null) await _uploadToDrive(newest, File(newest.path!));
      }
    } catch (e) {
      // The app must start even if the automatic backup fails.
      debugPrint('Automatic backup failed: $e');
    }
  }

  @override
  Future<String> connectDrive() => _drive.connect();

  @override
  Future<void> disconnectDrive() async {
    await _drive.disconnect();
    await _settings.write(AppConstants.settingDrivePending, null);
  }

  @override
  Future<void> restore(BackupFile backup) async {
    Directory? temp;
    try {
      final File zip;
      if (backup.isOnDrive) {
        temp = await Directory.systemTemp.createTemp('school_download_');
        try {
          zip = await _drive.download(backup, temp);
        } on DriveOfflineException {
          throw const BackupException(_offlineText);
        }
      } else {
        zip = File(backup.path!);
        if (!await zip.exists()) {
          throw const BackupException('This backup file was not found.');
        }
      }

      // A safety copy of the current data, in case the restore is a mistake.
      final now = _clock();
      await _files.createBackup(
        _db,
        await _backupDir(),
        now,
        name: 'school_before_restore_${AppDateUtils.backupStamp(now)}.zip',
      );
      await _files.restore(zip, _db);
    } on FileSystemException {
      throw const BackupException(
        'The backup could not be restored. Check that there is free space and try again.',
      );
    } finally {
      if (temp != null && await temp.exists()) await temp.delete(recursive: true);
    }
  }
}
