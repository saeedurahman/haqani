import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/google_config.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/backup_models.dart';
import '../domain/google_drive_service.dart';
import 'settings_store.dart';

/// Google Drive with the "drive.file" permission: the app can only see the
/// files it made itself, inside the folder "School Backups".
class GoogleDriveServiceImpl implements GoogleDriveService {
  GoogleDriveServiceImpl(this._settings);

  final SettingsStore _settings;

  static const folderName = 'School Backups';
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _folderMime = 'application/vnd.google-apps.folder';

  @override
  bool get isConfigured => GoogleConfig.isConfigured;

  ClientId get _clientId => ClientId(GoogleConfig.clientId, GoogleConfig.clientSecret);

  @override
  Future<String?> connectedEmail() async {
    if (!isConfigured) return null;
    return _settings.read(AppConstants.settingDriveEmail);
  }

  @override
  Future<String> connect() async {
    if (!isConfigured) throw const BackupException(_notConfigured);
    try {
      final client = await clientViaUserConsent(_clientId, _scopes, (url) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      });
      try {
        final about = await drive.DriveApi(client).about.get($fields: 'user(emailAddress)');
        final email = about.user?.emailAddress ?? 'Google account';
        await _settings.write(
          AppConstants.settingDriveCredentials,
          jsonEncode(client.credentials.toJson()),
        );
        await _settings.write(AppConstants.settingDriveEmail, email);
        return email;
      } finally {
        client.close();
      }
    } on UserConsentException {
      throw const BackupException('Google access was not allowed, so Drive was not connected.');
    } on SocketException {
      throw const BackupException('No internet connection. Connect to the internet and try again.');
    } on http.ClientException {
      throw const BackupException('No internet connection. Connect to the internet and try again.');
    }
  }

  @override
  Future<void> disconnect() async {
    await _settings.write(AppConstants.settingDriveCredentials, null);
    await _settings.write(AppConstants.settingDriveEmail, null);
  }

  @override
  Future<BackupFile> upload(File zip) {
    return _withApi((api) async {
      final folderId = await _folderId(api);
      final length = await zip.length();
      final created = await api.files.create(
        drive.File(name: p.basename(zip.path), parents: [folderId]),
        uploadMedia: drive.Media(zip.openRead(), length),
        $fields: 'id,name,size,createdTime',
      );
      return _toBackup(created);
    });
  }

  @override
  Future<List<BackupFile>> list() {
    return _withApi((api) async {
      final folderId = await _folderId(api);
      final result = await api.files.list(
        q: "'$folderId' in parents and trashed = false",
        orderBy: 'createdTime desc',
        pageSize: 100,
        $fields: 'files(id,name,size,createdTime)',
      );
      return [for (final f in result.files ?? const <drive.File>[]) _toBackup(f)];
    });
  }

  @override
  Future<File> download(BackupFile file, Directory folder) {
    return _withApi((api) async {
      final media = await api.files.get(
        file.driveId!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      await folder.create(recursive: true);
      final target = File(p.join(folder.path, file.name));
      final sink = target.openWrite();
      try {
        await media.stream.pipe(sink);
      } catch (_) {
        await sink.close();
        rethrow;
      }
      return target;
    });
  }

  static const _notConfigured =
      'Google Drive is not set up on this computer. Ask the person who installed the app '
      'to add the Google client ID (see README).';

  /// Runs [action] with a signed-in Drive client. Turns network problems into
  /// [DriveOfflineException] and a lost login into a friendly [BackupException].
  Future<T> _withApi<T>(Future<T> Function(drive.DriveApi api) action) async {
    if (!isConfigured) throw const BackupException(_notConfigured);
    final raw = await _settings.read(AppConstants.settingDriveCredentials);
    if (raw == null) throw const BackupException('Google Drive is not connected.');

    final base = http.Client();
    try {
      final credentials = AccessCredentials.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final client = autoRefreshingClient(_clientId, credentials, base);
      // A refreshed token is saved, so the login lasts.
      final sub = client.credentialUpdates.listen((c) {
        _settings.write(AppConstants.settingDriveCredentials, jsonEncode(c.toJson()));
      });
      try {
        return await action(drive.DriveApi(client)).timeout(const Duration(minutes: 10));
      } finally {
        await sub.cancel();
        client.close();
      }
    } on SocketException {
      throw const DriveOfflineException();
    } on http.ClientException {
      throw const DriveOfflineException();
    } on TimeoutException {
      throw const DriveOfflineException();
    } on AccessDeniedException {
      await disconnect();
      throw const BackupException('Google Drive login ended. Please connect Google Drive again.');
    } on drive.DetailedApiRequestError catch (e) {
      if (e.status == 401 || e.status == 403) {
        throw const BackupException(
          'Google Drive did not allow this. Please connect Google Drive again.',
        );
      }
      throw BackupException('Google Drive gave an error (${e.status}). Please try again later.');
    } finally {
      base.close();
    }
  }

  Future<String> _folderId(drive.DriveApi api) async {
    final found = await api.files.list(
      q: "mimeType = '$_folderMime' and name = '$folderName' and trashed = false",
      pageSize: 1,
      $fields: 'files(id)',
    );
    final existing = found.files?.firstOrNull?.id;
    if (existing != null) return existing;
    final created = await api.files.create(
      drive.File(name: folderName, mimeType: _folderMime),
      $fields: 'id',
    );
    return created.id!;
  }

  BackupFile _toBackup(drive.File f) {
    return BackupFile(
      name: f.name ?? 'backup.zip',
      size: int.tryParse(f.size ?? '') ?? 0,
      createdAt: f.createdTime?.toLocal() ?? DateTime.now(),
      driveId: f.id,
    );
  }
}
