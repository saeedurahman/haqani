import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/staff/presentation/pages/staff_flow.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    // Real font, so overflow checks match the app.
    final loader = FontLoader('Inter');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await loader.load();
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(database: db);
  });

  tearDown(() async {
    await db.close();
    await GetIt.instance.reset();
  });

  Future<void> pumpFlow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: StaffFlow()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pumpAndSettle();
  }

  testWidgets('empty list, then add a person through the form', (tester) async {
    await pumpFlow(tester);
    expect(find.text('No staff yet'), findsOneWidget);

    await tester.tap(find.text('Add Staff').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save Staff'));
    await tester.tap(find.text('Save Staff'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Sana Khan');
    await tester.enterText(find.byType(TextFormField).at(2), 'Teacher');
    await tester.enterText(find.byType(TextFormField).at(3), '123');
    await tester.ensureVisible(find.text('Save Staff'));
    await tester.tap(find.text('Save Staff'));
    await tester.pumpAndSettle();
    expect(find.text('Use format 0300-1234567'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), '0300-1234567');
    await tester.tap(find.text('Save Staff'));
    await settle(tester);

    expect(find.text('Staff added.'), findsOneWidget);
    expect(find.text('Sana Khan'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
  });

  testWidgets('search narrows the list; mark as left hides the person', (tester) async {
    await tester.runAsync(() async {
      await db.into(db.staff).insert(StaffCompanion.insert(name: 'Sana Khan'));
      await db.into(db.staff).insert(StaffCompanion.insert(name: 'Ali Raza'));
    });
    await pumpFlow(tester);
    expect(find.text('Ali Raza'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'sana');
    await settle(tester);
    expect(find.text('Ali Raza'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await settle(tester);

    await tester.tap(find.text('Ali Raza'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mark as Left'));
    await tester.tap(find.text('Mark as Left'));
    await tester.pumpAndSettle();
    expect(find.text('Mark Ali Raza as left?'), findsOneWidget);
    await tester.tap(find.text('Mark as Left').last);
    await settle(tester);
    expect(find.text('Make Active'), findsOneWidget);

    await tester.pageBack();
    await settle(tester);
    expect(find.text('Ali Raza'), findsNothing);
    expect(find.text('Sana Khan'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Left'), findsOneWidget);
  });
}
