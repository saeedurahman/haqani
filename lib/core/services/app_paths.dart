import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the app keeps its files: the database, attached documents and backups.
/// Everything is inside `Documents/RozatulAtfal`.
class AppPaths {
  /// Tests pass a temporary folder as [root].
  AppPaths({this._root});

  final Directory? _root;

  static const databaseFileName = 'school.sqlite';

  Future<Directory> root() async {
    final fixed = _root;
    final dir = fixed ??
        Directory(p.join((await getApplicationDocumentsDirectory()).path, 'RozatulAtfal'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> databaseFile() async => File(p.join((await root()).path, databaseFileName));

  /// Attached student documents.
  Future<Directory> documentsDir() async => Directory(p.join((await root()).path, 'documents'));

  /// Used when nobody chose a backup folder.
  Future<Directory> defaultBackupDir() async => Directory(p.join((await root()).path, 'Backups'));
}
