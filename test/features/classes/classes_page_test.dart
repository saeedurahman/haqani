import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/classes/presentation/pages/classes_page.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(database: db);
  });

  tearDown(() async {
    await db.close();
    await GetIt.instance.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: ClassesPage()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state, then adds a class and a section',
      (tester) async {
    await pumpPage(tester);
    expect(find.text('No classes yet'), findsOneWidget);

    await tester.tap(find.text('Add Class').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Class 1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Class 1'), findsOneWidget);
    expect(find.text('Class added.'), findsOneWidget);
    expect(find.text('No sections yet.'), findsOneWidget);

    await tester.tap(find.text('Add Section'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'A');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('No class teacher'), findsOneWidget);
  });

  testWidgets('asks before deleting and shows the block message',
      (tester) async {
    await tester.runAsync(() async {
      final id = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Nursery'),
          );
      await db.into(db.sections).insert(
            SectionsCompanion.insert(classId: id, name: 'Rose'),
          );
    });
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Delete class'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Nursery?'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('has sections'), findsOneWidget);
    expect(find.text('Nursery'), findsOneWidget);
  });
}
