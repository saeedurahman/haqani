import 'school_profile.dart';

/// Methods throw [SettingsException] when the input is not accepted.
abstract class SettingsRepository {
  Future<SchoolProfile> getProfile();

  /// Name is required. Address and phone may be empty.
  Future<void> saveProfile({required String name, String address = '', String phone = ''});

  /// Copies the picture (png or jpg, up to 5 MB) into the app folder.
  Future<void> setLogo(String sourcePath);

  Future<void> removeLogo();

  /// Folder where the database, documents and logo are kept.
  Future<String> getDataFolder();
}
