import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/services/app_paths.dart';
import 'package:haqani/features/backup/data/backup_file_service.dart';
import 'package:haqani/features/backup/domain/backup_models.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late AppPaths paths;
  late BackupFileService service;
  late AppDatabase db;
  late Directory backups;
  final now = DateTime(2026, 5, 12, 9, 30);

  Future<AppDatabase> openDb() async =>
      AppDatabase.forTesting(NativeDatabase(await paths.databaseFile()));

  Future<int> addStudent(AppDatabase d, String name) {
    return d.into(d.students).insert(
          StudentsCompanion.insert(admissionNo: name, name: name),
        );
  }

  Future<File> writeDoc(String relative, String text) async {
    final f = File(p.join((await paths.documentsDir()).path, relative));
    await f.parent.create(recursive: true);
    return f..writeAsStringSync(text);
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('backup_test_');
    paths = AppPaths(root: root);
    service = BackupFileService(paths);
    db = await openDb();
    backups = Directory(p.join(root.path, 'Backups'));
  });

  tearDown(() async {
    try {
      await db.close();
    } catch (_) {}
    await root.delete(recursive: true);
  });

  group('file names', () {
    test('backup names follow school_backup_YYYY-MM-DD_HH-mm.zip', () {
      expect(BackupFileService.fileName(now), 'school_backup_2026-05-12_09-30.zip');
      expect(BackupFileService.isBackupName('school_backup_2026-05-12_09-30.zip'), isTrue);
      expect(BackupFileService.isBackupName('school_before_restore_2026-05-12_09-30.zip'), isFalse);
      expect(BackupFileService.isBackupName('notes.zip'), isFalse);
      expect(BackupFileService.isBackupName('school_backup_2026-05-12_09-30.zip.part'), isFalse);
    });
  });

  group('createBackup', () {
    test('zip holds the database, documents and an info file; no temporary file is left', () async {
      await addStudent(db, 'Ali');
      await writeDoc('1/bform.txt', 'hello');
      await writeDoc('2/deep/cert.txt', 'world');

      final zip = await service.createBackup(db, backups, now);

      expect(p.basename(zip.path), 'school_backup_2026-05-12_09-30.zip');
      expect(backups.listSync().map((e) => p.basename(e.path)), ['school_backup_2026-05-12_09-30.zip']);
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      expect(archive.files.map((f) => f.name).toSet(), {
        'school.sqlite',
        'documents/1/bform.txt',
        'documents/2/deep/cert.txt',
        'backup_info.json',
      });
      final info = jsonDecode(utf8.decode(archive.findFile('backup_info.json')!.content)) as Map;
      expect(info['schemaVersion'], db.schemaVersion);
      expect(info['createdAt'], now.toIso8601String());
      final header = archive.findFile('school.sqlite')!.content as List<int>;
      expect(String.fromCharCodes(header.take(15)), 'SQLite format 3');
    });

    test('works without any documents, and creates the folder', () async {
      final zip = await service.createBackup(db, backups, now);

      expect(zip.existsSync(), isTrue);
      expect(ZipDecoder().decodeBytes(zip.readAsBytesSync()).files.map((f) => f.name),
          isNot(contains(startsWith('documents/'))));
    });

    test('a second backup in the same minute replaces the first', () async {
      await service.createBackup(db, backups, now);
      final zip = await service.createBackup(db, backups, now);

      expect(backups.listSync(), hasLength(1));
      expect(zip.existsSync(), isTrue);
    });

    test('an own file name can be given', () async {
      final zip = await service.createBackup(db, backups, now, name: 'school_before_restore_x.zip');

      expect(p.basename(zip.path), 'school_before_restore_x.zip');
    });
  });

  group('list and prune', () {
    Future<void> make(int count) async {
      for (var i = 0; i < count; i++) {
        File(p.join(backups.path, 'school_backup_2026-05-${(i + 1).toString().padLeft(2, '0')}_10-00.zip'))
          ..createSync(recursive: true)
          ..writeAsStringSync('x' * (i + 1));
      }
    }

    test('lists only backup files, newest first, with size', () async {
      await make(3);
      File(p.join(backups.path, 'school_before_restore_2026-05-20_10-00.zip')).writeAsStringSync('y');
      File(p.join(backups.path, 'readme.txt')).writeAsStringSync('z');

      final list = await service.listBackups(backups);

      expect(list.map((b) => b.name), [
        'school_backup_2026-05-03_10-00.zip',
        'school_backup_2026-05-02_10-00.zip',
        'school_backup_2026-05-01_10-00.zip',
      ]);
      expect(list.first.size, 3);
      expect(list.first.path, isNotNull);
    });

    test('a folder that does not exist has no backups', () async {
      expect(await service.listBackups(Directory(p.join(root.path, 'nope'))), isEmpty);
    });

    test('prune keeps the newest N and leaves other files alone', () async {
      await make(12);
      File(p.join(backups.path, 'school_before_restore_2026-01-01_10-00.zip')).writeAsStringSync('keep');

      await service.prune(backups, keep: 10);

      final names = backups.listSync().map((e) => p.basename(e.path)).toList()..sort();
      expect(names, hasLength(11));
      expect(names, isNot(contains('school_backup_2026-05-01_10-00.zip')));
      expect(names, isNot(contains('school_backup_2026-05-02_10-00.zip')));
      expect(names, contains('school_backup_2026-05-12_10-00.zip'));
      expect(names, contains('school_before_restore_2026-01-01_10-00.zip'));
    });
  });

  group('restore', () {
    test('brings back changed data and documents, and removes files that were added later', () async {
      final id = await addStudent(db, 'Ali');
      await db.into(db.studentDocuments).insert(StudentDocumentsCompanion.insert(
            studentId: id,
            title: 'B-Form',
            filePath: (await writeDoc('1/bform.txt', 'original')).path,
          ));
      final zip = await service.createBackup(db, backups, now);

      await (db.update(db.students)..where((t) => t.id.equals(id)))
          .write(const StudentsCompanion(name: Value('Changed')));
      await writeDoc('1/bform.txt', 'changed');
      await writeDoc('9/new.txt', 'added later');

      await service.restore(zip, db);

      final fresh = await openDb();
      addTearDown(fresh.close);
      expect((await fresh.select(fresh.students).get()).map((s) => s.name), ['Ali']);
      final docs = await paths.documentsDir();
      expect(File(p.join(docs.path, '1', 'bform.txt')).readAsStringSync(), 'original');
      expect(File(p.join(docs.path, '9', 'new.txt')).existsSync(), isFalse);
    });

    test('closes the database it was given', () async {
      final zip = await service.createBackup(db, backups, now);

      await service.restore(zip, db);

      expect(() => db.select(db.students).get(), throwsA(anything));
    });

    test('document paths from another computer are moved to this computer\'s folder', () async {
      final id = await addStudent(db, 'Ali');
      await db.into(db.studentDocuments).insert(StudentDocumentsCompanion.insert(
            studentId: id,
            title: 'Old PC',
            filePath: r'C:\Users\Other\Documents\RozatulAtfal\documents\1\bform.pdf',
          ));
      await db.into(db.studentDocuments).insert(StudentDocumentsCompanion.insert(
            studentId: id,
            title: 'Unusual',
            filePath: '/somewhere/else/file.pdf',
          ));
      await writeDoc('1/bform.pdf', 'pdf');
      final zip = await service.createBackup(db, backups, now);

      await service.restore(zip, db);

      final fresh = await openDb();
      addTearDown(fresh.close);
      final rows = await fresh.select(fresh.studentDocuments).get();
      final docs = (await paths.documentsDir()).path;
      expect(rows.firstWhere((r) => r.title == 'Old PC').filePath, p.join(docs, '1', 'bform.pdf'));
      expect(File(rows.firstWhere((r) => r.title == 'Old PC').filePath).existsSync(), isTrue);
      expect(rows.firstWhere((r) => r.title == 'Unusual').filePath, '/somewhere/else/file.pdf');
    });

    test('a file that is not a zip is refused and the database stays open and unchanged', () async {
      await addStudent(db, 'Ali');
      final bad = File(p.join(root.path, 'bad.zip'))..writeAsStringSync('not a zip');

      await expectLater(service.restore(bad, db), throwsA(isA<BackupException>()));

      expect((await db.select(db.students).get()), hasLength(1));
    });

    Future<File> zipWith(String name, List<int> content) async {
      final archive = Archive()..add(ArchiveFile.bytes(name, content));
      final file = File(p.join(root.path, 'custom.zip'));
      await file.writeAsBytes(ZipEncoder().encode(archive));
      return file;
    }

    test('a zip without a database is refused', () async {
      final zip = await zipWith('readme.txt', utf8.encode('hello'));

      await expectLater(
        service.restore(zip, db),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('database is missing'))),
      );
      expect(await db.select(db.students).get(), isEmpty, reason: 'database still open');
    });

    test('a database file that is damaged is refused', () async {
      final zip = await zipWith('school.sqlite', List.filled(200, 7));

      await expectLater(
        service.restore(zip, db),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('damaged'))),
      );
    });

    test('a backup from an older app version (before fee payments) is accepted', () async {
      final zip = await service.createBackup(db, backups, now);
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      final bytes = List<int>.of(archive.findFile('school.sqlite')!.content as List<int>);
      bytes[63] = 1;
      final older = await zipWith('school.sqlite', bytes);

      await expectLater(service.restore(older, db), completes);
    });

    test('a backup from a newer app version is refused', () async {
      final zip = await service.createBackup(db, backups, now);
      final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
      final bytes = List<int>.of(archive.findFile('school.sqlite')!.content as List<int>);
      bytes[63] = db.schemaVersion + 1;
      final newer = await zipWith('school.sqlite', bytes);

      await expectLater(
        service.restore(newer, db),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('newer version'))),
      );
      expect(await db.select(db.students).get(), isEmpty);
    });
  });
}
