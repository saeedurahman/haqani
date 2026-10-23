import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/app.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/services/app_paths.dart';
import 'package:haqani/core/widgets/school_logo.dart';
import 'package:haqani/features/settings/data/settings_repository_impl.dart';
import 'package:haqani/features/settings/domain/settings_repository.dart';
import 'package:haqani/features/settings/presentation/cubit/school_profile_cubit.dart';

void main() {
  late AppDatabase db;
  late Directory root;

  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await loader.load();
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('settings_page_');
    configureDependencies(database: db);
    // Keep the logo and data inside a temporary folder.
    getIt.unregister<AppPaths>();
    getIt.registerSingleton<AppPaths>(AppPaths(root: root));
    getIt.unregister<SchoolProfileCubit>();
    getIt.unregister<SettingsRepository>();
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt(), getIt<AppPaths>()),
    );
    getIt.registerLazySingleton<SchoolProfileCubit>(() => SchoolProfileCubit(getIt()));
  });

  tearDown(() async {
    await db.close();
    await GetIt.instance.reset();
    await root.delete(recursive: true);
  });

  Future<void> openSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SchoolApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Settings').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('shows school information, logo and data cards', (tester) async {
    await openSettings(tester);

    expect(find.text('School information'), findsOneWidget);
    expect(find.text('School logo'), findsOneWidget);
    expect(find.text('Data and backup'), findsOneWidget);
    expect(find.text('No logo yet.'), findsOneWidget);
    expect(find.text('Choose Picture'), findsOneWidget);
    expect(find.textContaining('Version 1.0.0'), findsOneWidget);
    expect(find.text(root.path), findsOneWidget);
  });

  testWidgets('changing the school name updates the side menu at once', (tester) async {
    await openSettings(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Iqra Model School');
    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    expect(find.text('School information saved.'), findsOneWidget);
    // Once in the side menu, once in the name box.
    expect(find.text('Iqra Model School'), findsNWidgets(2));
  });

  testWidgets('an empty school name is refused with a red message', (tester) async {
    await openSettings(tester);

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('School name is required'), findsOneWidget);
  });

  testWidgets('"Go to Backup" opens the Backup page', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Go to Backup'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Keep a safe copy of all school data'), findsOneWidget);
  });

  testWidgets('a logo shows in the side menu; removing it brings the default picture back', (tester) async {
    await openSettings(tester);
    final repo = getIt<SettingsRepository>();
    final pic = File('${root.path}/pic.png')
      ..writeAsBytesSync(base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='));
    await tester.runAsync(() async {
      await repo.setLogo(pic.path);
      await getIt<SchoolProfileCubit>().load();
    });
    await tester.pumpAndSettle();

    // The first SchoolLogo in the tree is the one in the side menu.
    expect(tester.widgetList<SchoolLogo>(find.byType(SchoolLogo)).first.path, isNotNull);

    await tester.runAsync(() async {
      await repo.removeLogo();
      await getIt<SchoolProfileCubit>().load();
    });
    await tester.pumpAndSettle();
    expect(tester.widgetList<SchoolLogo>(find.byType(SchoolLogo)).first.path, isNull);
  });
}
