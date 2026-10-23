import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/services/app_restarter.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/backup/domain/backup_models.dart';
import 'package:haqani/features/backup/domain/backup_repository.dart';
import 'package:haqani/features/backup/presentation/pages/backup_page.dart';

import '../../support/fake_backup_repository.dart';

void main() {
  late AppDatabase db;
  late FakeBackupRepository repo;
  late FakeRestarter restarter;

  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await loader.load();
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(database: db);
    repo = FakeBackupRepository();
    restarter = FakeRestarter();
    getIt.unregister<BackupRepository>();
    getIt.registerSingleton<BackupRepository>(repo);
    getIt.unregister<AppRestarter>();
    getIt.registerSingleton<AppRestarter>(restarter);
  });

  tearDown(() async {
    await db.close();
    await GetIt.instance.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: BackupPage()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
  }

  testWidgets('first look: no backup yet, folder shown, Drive explained', (tester) async {
    await pumpPage(tester);

    expect(find.text('No backup yet'), findsOneWidget);
    expect(find.text('Back Up Now'), findsOneWidget);
    expect(find.text(r'C:\Backups'), findsOneWidget);
    expect(find.text('Connect Google Drive'), findsOneWidget);
    expect(find.text('No backups yet. Press Back Up Now.'), findsOneWidget);
  });

  testWidgets('Back Up Now saves a backup and shows it in the list', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Back Up Now'));
    await settle(tester);

    expect(repo.backups, 1);
    expect(find.textContaining('Backup saved on this computer'), findsOneWidget);
    expect(find.text('No backup yet'), findsNothing);
    expect(find.text('Restore'), findsOneWidget);
    expect(find.textContaining('school_backup_2026-05-12_09-30.zip  |  2.0 KB'), findsOneWidget);
  });

  testWidgets('Google Drive not set up on this computer shows an explanation, not a button', (tester) async {
    repo.settings = const BackupSettings(folder: r'C:\Backups', isDefaultFolder: true);

    await pumpPage(tester);

    expect(find.textContaining('not set up on this computer'), findsOneWidget);
    expect(find.text('Connect Google Drive'), findsNothing);
  });

  testWidgets('connect Drive, then the Drive tab appears and loads on request', (tester) async {
    repo.drive = [
      BackupFile(name: 'school_backup_2026-04-01_10-00.zip', size: 5000, createdAt: DateTime(2026, 4, 1, 10), driveId: 'a'),
    ];
    await pumpPage(tester);

    await tester.tap(find.text('Connect Google Drive'));
    await settle(tester);
    expect(find.text('school@example.com'), findsOneWidget);
    expect(find.text('Disconnect'), findsOneWidget);

    await tester.tap(find.text('On Google Drive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load backups from Google Drive'));
    await settle(tester);

    expect(find.textContaining('school_backup_2026-04-01_10-00.zip'), findsOneWidget);
  });

  testWidgets('Drive upload problems are shown but the local backup still counts', (tester) async {
    repo.driveStatus = DriveUploadStatus.offline;
    repo.driveMessage = 'There is no internet, so the backup was not uploaded to Google Drive.';
    await pumpPage(tester);

    await tester.tap(find.text('Back Up Now'));
    await settle(tester);

    expect(find.textContaining('no internet'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
  });

  testWidgets('restore asks first, then asks to restart; the app restarts only on the button', (tester) async {
    repo.local = [
      BackupFile(
        name: 'school_backup_2026-05-01_10-00.zip',
        size: 1000,
        createdAt: DateTime(2026, 5, 1, 10),
        path: r'C:\Backups\school_backup_2026-05-01_10-00.zip',
      ),
    ];
    await pumpPage(tester);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Restore this backup?'), findsOneWidget);
    expect(find.textContaining('ALL current students'), findsOneWidget);

    // Cancel: nothing happens.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.restored, isNull);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore').last);
    await settle(tester);

    expect(repo.restored?.name, 'school_backup_2026-05-01_10-00.zip');
    expect(find.text('Restore complete'), findsOneWidget);
    expect(restarter.restarts, 0);

    await tester.tap(find.text('Restart App'));
    await tester.pumpAndSettle();
    expect(restarter.restarts, 1);
  });

  testWidgets('a refused restore shows the reason and no restart dialog', (tester) async {
    repo.local = [
      BackupFile(name: 'school_backup_x.zip', size: 10, createdAt: DateTime(2026, 5, 1), path: r'C:\x.zip'),
    ];
    repo.error = 'This file is not a valid backup.';
    await pumpPage(tester);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore').last);
    await settle(tester);

    expect(find.text('This file is not a valid backup.'), findsOneWidget);
    expect(find.text('Restore complete'), findsNothing);
  });

  testWidgets('"last backup" and the waiting upload are shown', (tester) async {
    repo.settings = BackupSettings(
      folder: r'C:\Backups',
      isDefaultFolder: false,
      lastBackup: DateTime(2026, 5, 12, 21, 5),
      driveConfigured: true,
      driveEmail: 'school@example.com',
      drivePending: true,
    );

    await pumpPage(tester);

    expect(find.text('Last backup'), findsOneWidget);
    expect(find.text('12 May 2026, 09:05 PM'), findsOneWidget);
    expect(find.textContaining('Waiting to upload to Google Drive'), findsOneWidget);
    expect(find.text('Chosen folder'), findsOneWidget);
    expect(find.text('Use the app folder'), findsOneWidget);
  });
}
