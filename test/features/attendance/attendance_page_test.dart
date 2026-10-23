import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/attendance/presentation/pages/attendance_page.dart';

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

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: AttendancePage()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('no classes shows a clear empty state', (tester) async {
    await pumpPage(tester);

    expect(find.text('No classes yet'), findsOneWidget);
  });

  testWidgets('mark, save, then see it in the daily and monthly reports', (tester) async {
    await tester.runAsync(() async {
      final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
      for (final (no, name) in [('1', 'Ali Raza'), ('2', 'Sara Noor')]) {
        await db.into(db.students).insert(
              StudentsCompanion.insert(admissionNo: no, name: name, classId: Value(c)),
            );
      }
    });
    await pumpPage(tester);

    // Everyone starts as present.
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Not saved yet. Press Save.'), findsOneWidget);

    // Tap Absent for the second student (second "Absent" button).
    await tester.tap(find.text('Absent').at(1));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    await tester.tap(find.text('Save Attendance'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Attendance saved.'), findsOneWidget);
    expect(find.text('Saved for this day.'), findsOneWidget);

    await tester.tap(find.text('Daily Report'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Not marked'), findsOneWidget, reason: 'only the count box, no student is unmarked');
    expect(find.text('Sara Noor'), findsOneWidget);

    await tester.tap(find.text('Monthly Report'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget, reason: 'Ali was present the only day');
    expect(find.text('0%'), findsOneWidget, reason: 'Sara was absent the only day');

    await tester.tap(find.text('Sara Noor'));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget);
  });
}
