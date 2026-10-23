import 'package:equatable/equatable.dart';

/// Thrown with a message that is safe to show to the user.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One backup file, on this computer or on Google Drive.
class BackupFile extends Equatable {
  const BackupFile({
    required this.name,
    required this.size,
    required this.createdAt,
    this.path,
    this.driveId,
  });

  final String name;

  /// Size in bytes.
  final int size;
  final DateTime createdAt;

  /// Set for a file on this computer.
  final String? path;

  /// Set for a file on Google Drive.
  final String? driveId;

  bool get isOnDrive => driveId != null;

  @override
  List<Object?> get props => [name, size, createdAt, path, driveId];
}

/// What the Backup page needs to know about the settings.
class BackupSettings extends Equatable {
  const BackupSettings({
    required this.folder,
    required this.isDefaultFolder,
    this.lastBackup,
    this.driveConfigured = false,
    this.driveEmail,
    this.drivePending = false,
  });

  /// The folder where backups are saved on this computer.
  final String folder;

  /// True when nobody chose a folder and the app folder is used.
  final bool isDefaultFolder;
  final DateTime? lastBackup;

  /// False when the Google client ID is not filled in on this computer.
  final bool driveConfigured;

  /// The connected Google account, or null when not connected.
  final String? driveEmail;

  /// True when the newest backup has not been uploaded to Drive yet.
  final bool drivePending;

  bool get driveConnected => driveEmail != null;

  @override
  List<Object?> get props =>
      [folder, isDefaultFolder, lastBackup, driveConfigured, driveEmail, drivePending];
}

enum DriveUploadStatus {
  /// Drive is not connected, so nothing was tried.
  notConnected,
  uploaded,

  /// No internet. The upload is queued for later.
  offline,
  failed,
}

/// Result of "Back up now".
class BackupResult extends Equatable {
  const BackupResult({required this.file, required this.drive, this.driveMessage});

  final BackupFile file;
  final DriveUploadStatus drive;

  /// Extra explanation when the Drive upload did not work.
  final String? driveMessage;

  @override
  List<Object?> get props => [file, drive, driveMessage];
}
