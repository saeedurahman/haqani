import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/features/backup/domain/backup_models.dart';
import 'package:haqani/features/backup/presentation/cubit/backup_cubit.dart';
import 'package:haqani/features/backup/presentation/cubit/backup_state.dart';

import '../../support/fake_backup_repository.dart';

void main() {
  late FakeBackupRepository repo;
  late FakeRestarter restarter;

  setUp(() {
    repo = FakeBackupRepository();
    restarter = FakeRestarter();
  });

  BackupCubit make() => BackupCubit(repo, restarter);

  final file = BackupFile(
    name: 'school_backup_2026-05-01_10-00.zip',
    size: 100,
    createdAt: DateTime(2026, 5, 1, 10),
    path: r'C:\Backups\school_backup_2026-05-01_10-00.zip',
  );

  test('load shows settings and local backups', () async {
    repo.local = [file];
    final cubit = make();

    await cubit.load();

    expect(cubit.state.status, BackupStatus.success);
    expect(cubit.state.settings?.folder, r'C:\Backups');
    expect(cubit.state.localBackups, [file]);
    await cubit.close();
  });

  test('load failure is friendly', () async {
    repo.failUnexpected = true;
    final cubit = make();

    await cubit.load();

    expect(cubit.state.status, BackupStatus.failure);
    expect(cubit.state.errorMessage, AppStrings.somethingWentWrong);
    await cubit.close();
  });

  group('backupNow', () {
    test('saved on this computer only', () async {
      final cubit = make();
      await cubit.load();

      await cubit.backupNow();

      expect(cubit.state.busy, BackupBusy.none);
      expect(cubit.state.feedback, 'Backup saved on this computer (school_backup_2026-05-12_09-30.zip).');
      expect(cubit.state.feedbackIsError, isFalse);
      expect(cubit.state.settings?.lastBackup, DateTime(2026, 5, 12, 9, 30));
      expect(cubit.state.localBackups, hasLength(1));
      await cubit.close();
    });

    test('also uploaded to Drive', () async {
      repo.driveStatus = DriveUploadStatus.uploaded;
      final cubit = make();
      await cubit.load();

      await cubit.backupNow();

      expect(cubit.state.feedback, contains('also uploaded to Google Drive'));
      expect(cubit.state.feedbackIsError, isFalse);
      await cubit.close();
    });

    test('Drive offline: saved here, shown as a warning with the reason', () async {
      repo.driveStatus = DriveUploadStatus.offline;
      repo.driveMessage = 'There is no internet, so the backup was not uploaded.';
      final cubit = make();
      await cubit.load();

      await cubit.backupNow();

      expect(cubit.state.feedback, startsWith('Backup saved on this computer'));
      expect(cubit.state.feedback, contains('no internet'));
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.localBackups, hasLength(1), reason: 'the backup itself worked');
      await cubit.close();
    });

    test('a failed backup shows the reason and is not busy any more', () async {
      repo.error = 'The backup could not be saved.';
      final cubit = make();
      await cubit.load();

      await cubit.backupNow();

      expect(cubit.state.feedback, 'The backup could not be saved.');
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.busy, BackupBusy.none);
      await cubit.close();
    });

    test('an unexpected error is friendly', () async {
      final cubit = make();
      await cubit.load();
      repo.failUnexpected = true;

      await cubit.backupNow();

      expect(cubit.state.feedback, AppStrings.somethingWentWrong);
      await cubit.close();
    });
  });

  test('changing the folder, and back to the default', () async {
    final cubit = make();
    await cubit.load();

    await cubit.setFolder(r'E:\USB');
    expect(cubit.state.settings?.folder, r'E:\USB');
    expect(cubit.state.feedback, 'Backup folder changed.');

    await cubit.setFolder(null);
    expect(cubit.state.settings?.isDefaultFolder, isTrue);
    expect(cubit.state.feedback, 'Backups are saved in the app folder.');

    repo.error = 'The backup cannot be saved in this folder. Please choose another folder.';
    await cubit.setFolder(r'Z:\nope');
    expect(cubit.state.feedbackIsError, isTrue);
    await cubit.close();
  });

  test('connect and disconnect Google Drive', () async {
    final cubit = make();
    await cubit.load();

    await cubit.connectDrive();
    expect(cubit.state.settings?.driveEmail, 'school@example.com');
    expect(cubit.state.feedback, 'Google Drive connected as school@example.com.');

    await cubit.disconnectDrive();
    expect(cubit.state.settings?.driveConnected, isFalse);
    expect(cubit.state.driveLoaded, isFalse);
    expect(cubit.state.feedback, contains('not deleted'));
    await cubit.close();
  });

  test('a refused Google connection shows the reason', () async {
    repo.error = 'Google access was not allowed, so Drive was not connected.';
    final cubit = make();
    await cubit.load();

    await cubit.connectDrive();

    expect(cubit.state.feedback, repo.error);
    expect(cubit.state.busy, BackupBusy.none);
    await cubit.close();
  });

  test('Drive backups are loaded on request', () async {
    repo.drive = [
      BackupFile(name: 'school_backup_x.zip', size: 5, createdAt: DateTime(2026, 5, 2), driveId: 'a'),
    ];
    final cubit = make();
    await cubit.load();
    expect(cubit.state.driveLoaded, isFalse);

    await cubit.loadDriveBackups();

    expect(cubit.state.driveLoaded, isTrue);
    expect(cubit.state.driveBackups.single.driveId, 'a');

    repo.error = 'No internet connection. Connect to the internet and try again.';
    await cubit.loadDriveBackups();
    expect(cubit.state.feedback, contains('No internet'));
    await cubit.close();
  });

  group('restore', () {
    test('success asks for a restart; the app only restarts when told to', () async {
      final cubit = make();
      await cubit.load();

      await cubit.restore(file);

      expect(repo.restored, file);
      expect(cubit.state.restored, isTrue);
      expect(cubit.state.busy, BackupBusy.none);
      expect(restarter.restarts, 0);

      await cubit.restartApp();
      expect(restarter.restarts, 1);
      await cubit.close();
    });

    test('a refused restore shows the reason and is not marked as restored', () async {
      repo.error = 'This file is not a valid backup.';
      final cubit = make();
      await cubit.load();

      await cubit.restore(file);

      expect(cubit.state.restored, isFalse);
      expect(cubit.state.feedback, 'This file is not a valid backup.');
      expect(cubit.state.busy, BackupBusy.none);
      await cubit.close();
    });

    test('an unexpected error says the data was not changed', () async {
      repo.failUnexpected = true;
      final cubit = make();
      repo.failUnexpected = false;
      await cubit.load();
      repo.failUnexpected = true;

      await cubit.restore(file);

      expect(cubit.state.feedback, contains('Your data was not changed'));
      await cubit.close();
    });
  });
}
