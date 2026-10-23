/// Copy this file to `google_config.dart` (same folder) and fill in the values.
/// `google_config.dart` is in `.gitignore` and must never be committed.
///
/// How to get the values (one time, by the person who sets up the school PC):
/// 1. Open https://console.cloud.google.com and create a project.
/// 2. Enable "Google Drive API" for the project.
/// 3. OAuth consent screen: type "External", add the school's Google account
///    as a test user.
/// 4. Credentials > Create credentials > OAuth client ID > "Desktop app".
/// 5. Copy the client ID and client secret here.
class GoogleConfig {
  const GoogleConfig._();

  static const clientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';
  static const clientSecret = 'YOUR_CLIENT_SECRET';

  /// False until real values are filled in. Drive backup stays off until then.
  static bool get isConfigured =>
      !clientId.startsWith('YOUR_') && !clientSecret.startsWith('YOUR_');
}
