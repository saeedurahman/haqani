import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/services/app_paths.dart';
import 'package:haqani/features/backup/data/backup_file_service.dart';
import 'package:haqani/features/backup/data/backup_repository_impl.dart';
import 'package:haqani/core/database/settings_store.dart';
import 'package:haqani/features/backup/domain/backup_models.dart';
import 'package:haqani/features/backup/domain/google_drive_service.dart';
import 'package:path/path.dart' as p;

class _FakeDrive implements GoogleDriveService {
  @override
  bool isConfigured = true;
  String? email;
  bool offline = false;
  bool failUpload = false;
  final uploaded = <String>[];
  List<BackupFile> files = [];
  File? fileToDownload;
  String? connectError;

  @override
  Future<String?> connectedEmail() async => email;

  @override
  Future<String> connect() async {
    if (connectError != null) throw BackupException(connectError!);
    email = 'school@example.com';
    return email!;
  }

  @override
  Future<void> disconnect() async => email = null;

  @override
  Future<BackupFile> upload(File zip) async {
    if (offline) throw const DriveOfflineException();
    if (failUpload) throw Exception('boom');
    uploaded.add(p.basename(zip.path));
    return BackupFile(name: p.basename(zip.path), size: 1, createdAt: DateTime.now(), driveId: 'id1');
  }

  @override
  Future<List<BackupFile>> list() async {
    if (offline) throw const DriveOfflineException();
    return files;
  }

  @override
  Future<File> download(BackupFile file, Directory folder) async {
    if (offline) throw const DriveOfflineException();
    final target = File(p.join(folder.path, file.name));
    return fileToDownload!.copy(target.path);
  }
}

void main() {
  late Directory root;
  late AppPaths paths;
  late AppDatabase db;
  late _FakeDrive drive;
  late SettingsStore settings;
  late BackupRepositoryImpl repo;
  var now = DateTime(2026, 5, 12, 9, 30);

  Future<AppDatabase> openDb() async =>
      AppDatabase.forTesting(NativeDatabase(await paths.databaseFile()));

  BackupRepositoryImpl makeRepo() => BackupRepositoryImpl(
        db: db,
        paths: paths,
        files: BackupFileService(paths),
        drive: drive,
        settings: settings,
        clock: () => now,
      );

  Future<Directory> defaultDir() => paths.defaultBackupDir();

  setUp(() async {
    now = DateTime(2026, 5, 12, 9, 30);
    root = await Directory.systemTemp.createTemp('backup_repo_');
    paths = AppPaths(root: root);
    db = await openDb();
    drive = _FakeDrive();
    settings = SettingsStore(db);
    repo = makeRepo();
  });

  tearDown(() async {
    try {
      await db.close();
    } catch (_) {}
    await root.delete(recursive: true);
  });

  group('settings', () {
    test('defaults: app folder, no backup yet, drive not connected', () async {
      final s = await repo.getSettings();

      expect(s.folder, (await defaultDir()).path);
      expect(s.isDefaultFolder, isTrue);
      expect(s.lastBackup, isNull);
      expect(s.driveConfigured, isTrue);
      expect(s.driveConnected, isFalse);
      expect(s.drivePending, isFalse);
    });

    test('choose a folder, then go back to the default', () async {
      final chosen = Directory(p.join(root.path, 'USB', 'School'));

      await repo.setBackupFolder(chosen.path);
      var s = await repo.getSettings();
      expect((s.folder, s.isDefaultFolder), (chosen.path, false));
      expect(chosen.existsSync(), isTrue);
      expect(chosen.listSync(), isEmpty, reason: 'test file removed');

      await repo.setBackupFolder(null);
      s = await repo.getSettings();
      expect(s.isDefaultFolder, isTrue);
    });

    test('a folder that cannot be written to is refused and not saved', () async {
      final file = File(p.join(root.path, 'afile'))..writeAsStringSync('x');

      await expectLater(
        repo.setBackupFolder(p.join(file.path, 'inside')),
        throwsA(isA<BackupException>()),
      );
      expect((await repo.getSettings()).isDefaultFolder, isTrue);
    });
  });

  group('backupNow', () {
    test('saves a zip in the folder and remembers the time', () async {
      final result = await repo.backupNow();

      expect(result.file.name, 'school_backup_2026-05-12_09-30.zip');
      expect(File(result.file.path!).existsSync(), isTrue);
      expect(result.file.size, greaterThan(0));
      expect(result.drive, DriveUploadStatus.notConnected);
      expect((await repo.getSettings()).lastBackup, now);
      expect((await repo.listLocalBackups()).map((b) => b.name), [result.file.name]);
    });

    test('uses the chosen folder', () async {
      final chosen = Directory(p.join(root.path, 'USB'));
      await repo.setBackupFolder(chosen.path);

      final result = await repo.backupNow();

      expect(p.dirname(result.file.path!), chosen.path);
    });

    test('keeps only the newest 10 backups', () async {
      for (var i = 0; i < 12; i++) {
        now = DateTime(2026, 5, 1 + i, 10, 0);
        await repo.backupNow();
      }

      final list = await repo.listLocalBackups();
      expect(list, hasLength(10));
      expect(list.first.name, 'school_backup_2026-05-12_10-00.zip');
      expect(list.last.name, 'school_backup_2026-05-03_10-00.zip');
    });

    test('uploads to Google Drive when connected', () async {
      drive.email = 'school@example.com';

      final result = await repo.backupNow();

      expect(result.drive, DriveUploadStatus.uploaded);
      expect(drive.uploaded, ['school_backup_2026-05-12_09-30.zip']);
      expect((await repo.getSettings()).drivePending, isFalse);
    });

    test('without internet the backup is kept and the upload is queued', () async {
      drive.email = 'school@example.com';
      drive.offline = true;

      final result = await repo.backupNow();

      expect(result.drive, DriveUploadStatus.offline);
      expect(result.driveMessage, contains('no internet'));
      expect(File(result.file.path!).existsSync(), isTrue);
      expect((await repo.getSettings()).drivePending, isTrue);
    });

    test('a Drive error does not lose the local backup', () async {
      drive.email = 'school@example.com';
      drive.failUpload = true;

      final result = await repo.backupNow();

      expect(result.drive, DriveUploadStatus.failed);
      expect(result.driveMessage, contains('saved on this computer'));
      expect((await repo.getSettings()).drivePending, isTrue);
    });

    test('a folder that cannot be used gives a clear message', () async {
      await settings.write(AppConstants.settingBackupFolder, p.join(root.path, 'afile', 'x'));
      File(p.join(root.path, 'afile')).writeAsStringSync('x');

      await expectLater(repo.backupNow(), throwsA(isA<BackupException>()));
    });
  });

  group('automatic backup', () {
    test('first start makes a backup; later the same day does nothing', () async {
      await repo.runAutoBackup();
      expect(await repo.listLocalBackups(), hasLength(1));

      now = DateTime(2026, 5, 12, 17, 0);
      await repo.runAutoBackup();
      expect(await repo.listLocalBackups(), hasLength(1));
    });

    test('the next day makes another one', () async {
      await repo.runAutoBackup();

      now = DateTime(2026, 5, 13, 8, 0);
      await repo.runAutoBackup();

      expect((await repo.listLocalBackups()).map((b) => b.name),
          ['school_backup_2026-05-13_08-00.zip', 'school_backup_2026-05-12_09-30.zip']);
    });

    test('uploads to Drive too, and never throws when the internet is down', () async {
      drive.email = 'school@example.com';
      drive.offline = true;

      await repo.runAutoBackup();

      expect(await repo.listLocalBackups(), hasLength(1));
      expect((await repo.getSettings()).drivePending, isTrue);
    });

    test('a waiting upload is sent later the same day, when the internet is back', () async {
      drive.email = 'school@example.com';
      drive.offline = true;
      await repo.runAutoBackup();

      drive.offline = false;
      now = DateTime(2026, 5, 12, 15, 0);
      await repo.runAutoBackup();

      expect(drive.uploaded, ['school_backup_2026-05-12_09-30.zip']);
      expect((await repo.getSettings()).drivePending, isFalse);
      expect(await repo.listLocalBackups(), hasLength(1), reason: 'no extra backup');
    });

    test('never throws even when the backup itself fails', () async {
      await settings.write(AppConstants.settingBackupFolder, p.join(root.path, 'afile', 'x'));
      File(p.join(root.path, 'afile')).writeAsStringSync('x');

      await repo.runAutoBackup();
    });
  });

  group('Google Drive', () {
    test('connect gives the email; the settings show it; disconnect clears it and the queue', () async {
      expect(await repo.connectDrive(), 'school@example.com');
      expect((await repo.getSettings()).driveEmail, 'school@example.com');

      await settings.write(AppConstants.settingDrivePending, '1');
      await repo.disconnectDrive();

      final s = await repo.getSettings();
      expect((s.driveConnected, s.drivePending), (false, false));
    });

    test('a refused connection shows the reason', () async {
      drive.connectError = 'Google access was not allowed, so Drive was not connected.';

      await expectLater(
        repo.connectDrive(),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('not allowed'))),
      );
    });

    test('lists Drive backups, and says clearly when offline', () async {
      drive.files = [BackupFile(name: 'school_backup_x.zip', size: 5, createdAt: now, driveId: 'a')];
      expect((await repo.listDriveBackups()).single.name, 'school_backup_x.zip');

      drive.offline = true;
      await expectLater(
        repo.listDriveBackups(),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('No internet'))),
      );
    });
  });

  group('restore', () {
    Future<int> student(String name) =>
        db.into(db.students).insert(StudentsCompanion.insert(admissionNo: name, name: name));

    test('from a local backup: data comes back and a safety copy of the current data is made', () async {
      await student('Ali');
      final backup = (await repo.backupNow()).file;
      await student('Added Later');
      now = DateTime(2026, 5, 12, 11, 0);

      await repo.restore(backup);

      final fresh = await openDb();
      addTearDown(fresh.close);
      expect((await fresh.select(fresh.students).get()).map((s) => s.name), ['Ali']);

      final names = (await defaultDir()).listSync().map((e) => p.basename(e.path)).toList();
      expect(names, contains('school_before_restore_2026-05-12_11-00.zip'));
      final safety = File(p.join((await defaultDir()).path, 'school_before_restore_2026-05-12_11-00.zip'));
      expect(safety.existsSync(), isTrue);
      // The database is closed after a restore (the app restarts), so read the folder directly.
      expect(await BackupFileService(paths).listBackups(await defaultDir()), hasLength(1),
          reason: 'safety copy is not listed as a normal backup');
    });

    test('from Drive: the file is downloaded first', () async {
      await student('Ali');
      final local = (await repo.backupNow()).file;
      drive.fileToDownload = File(local.path!);
      final onDrive = BackupFile(name: local.name, size: local.size, createdAt: now, driveId: 'a');
      await student('Added Later');

      await repo.restore(onDrive);

      final fresh = await openDb();
      addTearDown(fresh.close);
      expect((await fresh.select(fresh.students).get()).map((s) => s.name), ['Ali']);
    });

    test('from Drive without internet: clear message, data untouched', () async {
      await student('Ali');
      drive.offline = true;

      await expectLater(
        repo.restore(BackupFile(name: 'x.zip', size: 1, createdAt: now, driveId: 'a')),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('No internet'))),
      );
      expect(await db.select(db.students).get(), hasLength(1));
    });

    test('a backup file that is gone is reported', () async {
      await expectLater(
        repo.restore(BackupFile(name: 'x.zip', size: 1, createdAt: now, path: p.join(root.path, 'missing.zip'))),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('not found'))),
      );
    });

    test('a damaged file is refused and the current data stays', () async {
      await student('Ali');
      final bad = File(p.join(root.path, 'bad.zip'))..writeAsStringSync('nope');

      await expectLater(
        repo.restore(BackupFile(name: 'bad.zip', size: 4, createdAt: now, path: bad.path)),
        throwsA(isA<BackupException>()),
      );
      expect(await db.select(db.students).get(), hasLength(1));
    });
  });

  test('the dashboard reads the same "last backup" setting', () async {
    await repo.backupNow();

    final row = await (db.select(db.appSettings)
          ..where((t) => t.key.equals(AppConstants.settingLastBackup)))
        .getSingle();
    expect(DateTime.parse(row.value), now);
    expect(const Value(1).present, isTrue);
  });
}
