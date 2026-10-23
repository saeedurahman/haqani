import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/settings_store.dart';
import '../../../core/services/app_paths.dart';
import '../../../core/utils/pdf_school_header.dart';
import '../domain/school_profile.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store, this._paths, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final SettingsStore _store;
  final AppPaths _paths;
  final DateTime Function() _clock;

  static const _allowedExtensions = {'.png', '.jpg', '.jpeg'};
  static const _maxLogoBytes = 5 * 1024 * 1024;

  @override
  Future<SchoolProfile> getProfile() async {
    final logo = await _store.read(AppConstants.settingLogoPath);
    return SchoolProfile(
      name: await _store.read(AppConstants.settingSchoolName) ?? AppStrings.defaultSchoolName,
      address: await _store.read(AppConstants.settingSchoolAddress) ?? '',
      phone: await _store.read(AppConstants.settingSchoolPhone) ?? '',
      // A logo that was deleted from the disk is treated as no logo.
      logoPath: logo != null && await File(logo).exists() ? logo : null,
    );
  }

  @override
  Future<void> saveProfile({required String name, String address = '', String phone = ''}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw const SettingsException('School name is required.');
    await _store.write(AppConstants.settingSchoolName, cleanName);
    await _store.write(AppConstants.settingSchoolAddress, address.trim());
    await _store.write(AppConstants.settingSchoolPhone, phone.trim());
  }

  @override
  Future<void> setLogo(String sourcePath) async {
    final extension = p.extension(sourcePath).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw const SettingsException('Please choose a PNG or JPG picture.');
    }
    final source = File(sourcePath);
    if (!await source.exists()) throw const SettingsException('The picture was not found.');
    if (await source.length() > _maxLogoBytes) {
      throw const SettingsException('The picture is too big. Please choose one under 5 MB.');
    }

    final head = await source.openRead(0, 8).expand((b) => b).toList();
    if (!looksLikePicture(head)) {
      throw const SettingsException('This file is not a PNG or JPG picture.');
    }

    // A new file name each time, so the screen never shows an old cached picture.
    final root = await _paths.root();
    final target = File(p.join(root.path, 'logo_${_clock().millisecondsSinceEpoch}$extension'));
    await source.copy(target.path);

    final old = await _store.read(AppConstants.settingLogoPath);
    await _store.write(AppConstants.settingLogoPath, target.path);
    await _deleteQuietly(old);
  }

  @override
  Future<void> removeLogo() async {
    final old = await _store.read(AppConstants.settingLogoPath);
    await _store.write(AppConstants.settingLogoPath, null);
    await _deleteQuietly(old);
  }

  @override
  Future<String> getDataFolder() async => (await _paths.root()).path;

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // An old logo that cannot be deleted is harmless.
    }
  }
}
