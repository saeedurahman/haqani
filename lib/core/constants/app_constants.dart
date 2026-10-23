class AppConstants {
  const AppConstants._();

  static const sidebarWidth = 264.0;
  static const pagePadding = 32.0;
  static const maxContentWidth = 1280.0;
  static const keepLocalBackups = 10;

  static const settingSchoolName = 'school_name';
  static const settingSchoolAddress = 'school_address';
  static const settingLastBackup = 'last_backup_time';
  static const settingBackupFolder = 'backup_folder';
  static const settingDriveCredentials = 'drive_credentials';
  static const settingDriveEmail = 'drive_email';

  /// "1" while the newest local backup still has to be uploaded to Drive.
  static const settingDrivePending = 'drive_upload_pending';
}
