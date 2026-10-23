import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_strings.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/database/settings_store.dart';
import 'package:haqani/core/services/app_paths.dart';
import 'package:haqani/features/settings/data/settings_repository_impl.dart';
import 'package:haqani/features/settings/domain/school_profile.dart';
import 'package:haqani/features/settings/presentation/cubit/school_profile_cubit.dart';
import 'package:haqani/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:haqani/features/settings/presentation/cubit/settings_state.dart';
import 'package:path/path.dart' as p;

/// A real 1x1 PNG picture.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late AppDatabase db;
  late Directory root;
  late SettingsRepositoryImpl repo;
  var tick = 1000;

  File picture(String name, {List<int>? bytes}) {
    return File(p.join(root.path, 'picked', name))
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes ?? _png);
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('settings_test_');
    tick = 1000;
    repo = SettingsRepositoryImpl(
      SettingsStore(db),
      AppPaths(root: root),
      clock: () => DateTime.fromMillisecondsSinceEpoch(tick++),
    );
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  group('profile', () {
    test('starts with the default name and nothing else', () async {
      final profile = await repo.getProfile();

      expect(profile.name, AppStrings.defaultSchoolName);
      expect((profile.address, profile.phone, profile.logoPath), ('', '', null));
    });

    test('saves name, address and phone, trimmed', () async {
      await repo.saveProfile(name: '  Iqra Model School ', address: ' Main Road, Lahore ', phone: ' 042-1234567 ');

      final profile = await repo.getProfile();
      expect(profile.name, 'Iqra Model School');
      expect(profile.address, 'Main Road, Lahore');
      expect(profile.phone, '042-1234567');
    });

    test('the name is required; address and phone can be cleared', () async {
      await repo.saveProfile(name: 'School', address: 'A', phone: '1');

      await expectLater(repo.saveProfile(name: '  '), throwsA(isA<SettingsException>()));
      await repo.saveProfile(name: 'School');

      final profile = await repo.getProfile();
      expect((profile.address, profile.phone), ('', ''));
    });

    test('an Urdu school name is kept', () async {
      await repo.saveProfile(name: 'روضة الاطفال');

      expect((await repo.getProfile()).name, 'روضة الاطفال');
    });
  });

  group('logo', () {
    test('is copied into the app folder and shown in the profile', () async {
      final source = picture('mylogo.PNG');

      await repo.setLogo(source.path);

      final logo = (await repo.getProfile()).logoPath!;
      expect(p.dirname(logo), root.path);
      expect(p.basename(logo), startsWith('logo_'));
      expect(p.extension(logo), '.png');
      expect(File(logo).readAsBytesSync(), _png);
      expect(source.existsSync(), isTrue, reason: 'the original is not touched');
    });

    test('a new logo replaces the old file, with a new name', () async {
      await repo.setLogo(picture('a.png').path);
      final first = (await repo.getProfile()).logoPath!;

      await repo.setLogo(picture('b.jpg').path);

      final second = (await repo.getProfile()).logoPath!;
      expect(second, isNot(first));
      expect(File(first).existsSync(), isFalse);
      expect(File(second).existsSync(), isTrue);
      expect(Directory(root.path).listSync().whereType<File>().where((f) => p.basename(f.path).startsWith('logo_')),
          hasLength(1));
    });

    test('remove deletes the file and the setting', () async {
      await repo.setLogo(picture('a.png').path);
      final logo = (await repo.getProfile()).logoPath!;

      await repo.removeLogo();

      expect((await repo.getProfile()).logoPath, isNull);
      expect(File(logo).existsSync(), isFalse);
      await repo.removeLogo();
    });

    test('a wrong file type, a missing file and a huge file are refused', () async {
      await expectLater(
        repo.setLogo(picture('notes.txt').path),
        throwsA(isA<SettingsException>().having((e) => e.message, 'message', contains('PNG or JPG'))),
      );
      await expectLater(
        repo.setLogo(p.join(root.path, 'nope.png')),
        throwsA(isA<SettingsException>().having((e) => e.message, 'message', contains('not found'))),
      );
      await expectLater(
        repo.setLogo(picture('big.png', bytes: List.filled(5 * 1024 * 1024 + 1, 1)).path),
        throwsA(isA<SettingsException>().having((e) => e.message, 'message', contains('too big'))),
      );
      expect((await repo.getProfile()).logoPath, isNull);
    });

    test('a file with a picture name but other content is refused', () async {
      await expectLater(
        repo.setLogo(picture('fake.png', bytes: utf8.encode('this is text')).path),
        throwsA(isA<SettingsException>().having((e) => e.message, 'message', contains('not a PNG or JPG'))),
      );
      expect((await repo.getProfile()).logoPath, isNull);
    });

    test('a logo that was deleted from the disk counts as no logo', () async {
      await repo.setLogo(picture('a.png').path);
      File((await repo.getProfile()).logoPath!).deleteSync();

      expect((await repo.getProfile()).logoPath, isNull);
    });
  });

  test('data folder is the app folder', () async {
    expect(await repo.getDataFolder(), root.path);
  });

  group('SettingsCubit', () {
    late SchoolProfileCubit shared;
    late SettingsCubit cubit;

    setUp(() {
      shared = SchoolProfileCubit(repo);
      cubit = SettingsCubit(repo, shared);
    });

    tearDown(() async {
      await cubit.close();
      await shared.close();
    });

    test('load shows the profile and the data folder', () async {
      await cubit.load();

      expect(cubit.state.status, SettingsStatus.success);
      expect(cubit.state.profile?.name, AppStrings.defaultSchoolName);
      expect(cubit.state.dataFolder, root.path);
    });

    test('save reports success and updates the shared school profile (side menu)', () async {
      await cubit.load();

      await cubit.save(name: 'Iqra Model School', address: 'Lahore', phone: '042-1');

      expect(cubit.state.feedback, 'School information saved.');
      expect(cubit.state.feedbackIsError, isFalse);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.profile?.address, 'Lahore');
      expect(shared.state.profile.name, 'Iqra Model School');
    });

    test('an empty name shows the reason and changes nothing', () async {
      await cubit.load();

      await cubit.save(name: ' ');

      expect(cubit.state.feedback, 'School name is required.');
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.isSaving, isFalse);
      expect(shared.state.profile.name, AppStrings.defaultSchoolName);
    });

    test('logo: choose, then remove; a bad file shows the reason', () async {
      await cubit.load();

      await cubit.setLogo(picture('a.png').path);
      expect(cubit.state.feedback, 'Logo saved.');
      expect(shared.state.profile.logoPath, isNotNull);

      await cubit.removeLogo();
      expect(cubit.state.feedback, 'Logo removed.');
      expect(shared.state.profile.logoPath, isNull);

      await cubit.setLogo(picture('x.gif').path);
      expect(cubit.state.feedbackIsError, isTrue);
      expect(cubit.state.feedback, contains('PNG or JPG'));
    });
  });
}
