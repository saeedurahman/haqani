import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/backup/domain/backup_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SchoolApp());
  // Once a day, in the background. The app opens even if this fails.
  getIt<BackupRepository>().runAutoBackup();
}
