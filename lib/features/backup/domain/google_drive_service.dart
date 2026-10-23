import 'dart:io';

import 'backup_models.dart';

/// No internet, or Google could not be reached.
class DriveOfflineException implements Exception {
  const DriveOfflineException();
}

/// Talks to Google Drive. Everything goes into the folder "School Backups".
abstract class GoogleDriveService {
  /// False when the Google client ID and secret are not filled in.
  bool get isConfigured;

  /// The connected Google account, or null when not connected.
  Future<String?> connectedEmail();

  /// Opens the browser so the user can allow access. Returns the email.
  /// Throws [BackupException] with a friendly message when it fails.
  Future<String> connect();

  Future<void> disconnect();

  /// Uploads a backup zip. Throws [DriveOfflineException] without internet.
  Future<BackupFile> upload(File zip);

  /// Backups in the Drive folder, newest first.
  Future<List<BackupFile>> list();

  /// Downloads a backup into [folder] and returns the file.
  Future<File> download(BackupFile file, Directory folder);
}
