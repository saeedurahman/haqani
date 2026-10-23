import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/services/app_paths.dart';
import '../../../core/utils/app_date_utils.dart';
import '../domain/backup_models.dart';

/// Makes and opens backup zip files. A backup zip holds:
/// `school.sqlite`, the `documents/` folder and `backup_info.json`.
class BackupFileService {
  BackupFileService(this._paths);

  final AppPaths _paths;

  static const databaseEntry = 'school.sqlite';
  static const infoEntry = 'backup_info.json';
  static const documentsFolder = 'documents';

  /// Example: `school_backup_2026-05-12_09-30.zip`.
  static String fileName(DateTime now) => 'school_backup_${AppDateUtils.backupStamp(now)}.zip';

  static final _backupName = RegExp(r'^school_backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}\.zip$');

  static bool isBackupName(String name) => _backupName.hasMatch(name);

  /// Writes the zip into [folder] under [name] and returns it.
  /// The database is copied with `VACUUM INTO`, which is safe while the app is running.
  Future<File> createBackup(
    AppDatabase db,
    Directory folder,
    DateTime now, {
    String? name,
  }) async {
    await folder.create(recursive: true);
    final temp = await Directory.systemTemp.createTemp('school_backup_');
    try {
      final copy = File(p.join(temp.path, databaseEntry));
      final quoted = copy.path.replaceAll("'", "''");
      await db.customStatement("VACUUM INTO '$quoted'");

      final target = File(p.join(folder.path, name ?? fileName(now)));
      // Written under another name first, so a half-written file never looks like a backup.
      final partial = File('${target.path}.part');
      if (await partial.exists()) await partial.delete();

      final encoder = ZipFileEncoder()..create(partial.path);
      await encoder.addFile(copy, databaseEntry);
      final docs = await _paths.documentsDir();
      if (await docs.exists()) {
        await for (final entity in docs.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          final relative = p.relative(entity.path, from: docs.path).replaceAll(r'\', '/');
          await encoder.addFile(entity, '$documentsFolder/$relative');
        }
      }
      final info = utf8.encode(jsonEncode({
        'app': 'Rozatul Atfal School Management',
        'createdAt': now.toIso8601String(),
        'schemaVersion': db.schemaVersion,
      }));
      encoder.addArchiveFile(ArchiveFile.bytes(infoEntry, info));
      await encoder.close();

      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
      return target;
    } finally {
      await temp.delete(recursive: true);
    }
  }

  /// Backups in [folder], newest first.
  Future<List<BackupFile>> listBackups(Directory folder) async {
    if (!await folder.exists()) return [];
    final files = <BackupFile>[];
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is! File || !isBackupName(p.basename(entity.path))) continue;
      final stat = await entity.stat();
      files.add(BackupFile(
        name: p.basename(entity.path),
        size: stat.size,
        createdAt: stat.modified,
        path: entity.path,
      ));
    }
    files.sort((a, b) => b.name.compareTo(a.name));
    return files;
  }

  /// Deletes the oldest backups so that only the newest [keep] stay.
  Future<void> prune(Directory folder, {required int keep}) async {
    final all = await listBackups(folder);
    for (final old in all.skip(keep)) {
      await File(old.path!).delete();
    }
  }

  /// Replaces the database and documents with the ones in [zip].
  /// The open database [db] is closed, so the app has to restart afterwards.
  /// Throws [BackupException] if the file is not a usable backup.
  Future<void> restore(File zip, AppDatabase db) async {
    final temp = await Directory.systemTemp.createTemp('school_restore_');
    try {
      try {
        await extractFileToDisk(zip.path, temp.path);
      } catch (_) {
        throw const BackupException('This file is not a valid backup.');
      }
      final restoredDb = File(p.join(temp.path, databaseEntry));
      await _checkDatabase(restoredDb, db.schemaVersion);

      final dbFile = await _paths.databaseFile();
      final docs = await _paths.documentsDir();

      await db.close();
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final f = File('${dbFile.path}$suffix');
        if (await f.exists()) await f.delete();
      }
      await restoredDb.copy(dbFile.path);

      if (await docs.exists()) await docs.delete(recursive: true);
      await docs.create(recursive: true);
      final restoredDocs = Directory(p.join(temp.path, documentsFolder));
      if (await restoredDocs.exists()) {
        await _copyDirectory(restoredDocs, docs);
      }
      await _fixDocumentPaths(dbFile, docs);
    } finally {
      await temp.delete(recursive: true);
    }
  }

  /// SQLite files start with "SQLite format 3". The "user version" (which the
  /// app sets to its schema version) is stored at byte 60.
  Future<void> _checkDatabase(File file, int currentVersion) async {
    if (!await file.exists()) {
      throw const BackupException('This file is not a valid backup. The database is missing.');
    }
    final raf = await file.open();
    try {
      final header = await raf.read(100);
      const magic = 'SQLite format 3';
      if (header.length < 100 || String.fromCharCodes(header.take(magic.length)) != magic) {
        throw const BackupException('This file is not a valid backup. The database is damaged.');
      }
      final version = (header[60] << 24) | (header[61] << 16) | (header[62] << 8) | header[63];
      if (version > currentVersion) {
        throw const BackupException(
          'This backup was made by a newer version of the app. Please update the app first.',
        );
      }
    } finally {
      await raf.close();
    }
  }

  Future<void> _copyDirectory(Directory from, Directory to) async {
    await for (final entity in from.list(recursive: true, followLinks: false)) {
      final target = p.join(to.path, p.relative(entity.path, from: from.path));
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
      } else if (entity is File) {
        await Directory(p.dirname(target)).create(recursive: true);
        await entity.copy(target);
      }
    }
  }

  /// Attached documents are saved with their full path. A backup made on
  /// another computer (another user name) would point to the wrong folder, so
  /// the part after `documents` is kept and put under this computer's folder.
  Future<void> _fixDocumentPaths(File dbFile, Directory docs) async {
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    try {
      for (final row in await db.select(db.studentDocuments).get()) {
        final parts = p.split(row.filePath.replaceAll(r'\', '/'));
        final index = parts.lastIndexOf(documentsFolder);
        if (index < 0 || index == parts.length - 1) continue;
        final fixed = p.joinAll([docs.path, ...parts.sublist(index + 1)]);
        if (fixed != row.filePath) {
          await (db.update(db.studentDocuments)..where((t) => t.id.equals(row.id)))
              .write(StudentDocumentsCompanion(filePath: Value(fixed)));
        }
      }
    } finally {
      await db.close();
    }
  }
}
