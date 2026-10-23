import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/widgets/friendly_error.dart';
import 'features/backup/domain/backup_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Staff never see a red error screen or a crash: a broken widget shows a
  // short friendly message, and unexpected errors are only written to the log.
  // (In development the normal error screens stay, so problems are easy to find.)
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const FriendlyError();
    FlutterError.onError = (details) => debugPrint('Screen error: ${details.exceptionAsString()}');
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Unexpected error: $error');
      return true;
    };
  }

  configureDependencies();
  runApp(const SchoolApp());
  // Once a day, in the background. The app opens even if this fails.
  getIt<BackupRepository>().runAutoBackup();
}
