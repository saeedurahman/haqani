import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/exams/presentation/pages/exams_flow.dart';

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
      home: const Scaffold(body: ExamsFlow()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pumpAndSettle();
  }

  Future<void> seed() async {
    final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    for (final (no, name) in [('1', 'Ali Raza'), ('2', 'Sara Noor')]) {
      await db.into(db.students).insert(
            StudentsCompanion.insert(admissionNo: no, name: name, classId: Value(c)),
          );
    }
  }

  testWidgets('no classes: clear message instead of a broken button', (tester) async {
    await pumpFlow(tester);

    expect(find.text('No classes yet'), findsOneWidget);
  });

  testWidgets('add subjects, create an exam, enter marks, see results', (tester) async {
    await tester.runAsync(seed);
    await pumpFlow(tester);

    // Subjects.
    await tester.tap(find.text('Subjects'));
    await settle(tester);
    expect(find.text('No subjects for this class'), findsOneWidget);
    for (final (name, total) in [('English', '100'), ('Math', '50')]) {
      await tester.tap(find.text('Add Subject').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, name);
      await tester.enterText(find.byType(TextFormField).last, total);
      await tester.tap(find.text('Save'));
      await settle(tester);
    }
    expect(find.text('Total of all subjects: 150 marks'), findsOneWidget);

    // Exam.
    await tester.tap(find.text('Exams').last);
    await settle(tester);
    expect(find.text('No exams yet'), findsOneWidget);
    await tester.tap(find.text('Create Exam').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Annual 2026');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Exam created.'), findsOneWidget);
    expect(find.text('Annual 2026'), findsOneWidget);

    // Marks.
    await tester.tap(find.text('Annual 2026'));
    await settle(tester);
    expect(find.text('Ali Raza'), findsOneWidget);
    final boxes = find.byType(TextField);
    await tester.enterText(boxes.at(0), '90');
    await tester.enterText(boxes.at(1), '45');
    await tester.enterText(boxes.at(2), '60');
    await tester.enterText(boxes.at(3), '51');
    await tester.pumpAndSettle();
    expect(find.text('135/150'), findsOneWidget, reason: 'live total');
    expect(find.text('A mark is more than the total. Fix the red box.'), findsOneWidget);

    await tester.enterText(boxes.at(3), '30');
    await tester.pumpAndSettle();
    expect(find.text('You have changes that are not saved. Press Save Marks.'), findsOneWidget);
    await tester.tap(find.text('Save Marks'));
    await settle(tester);
    expect(find.text('Marks saved.'), findsOneWidget);

    // Results.
    await tester.tap(find.text('Results'));
    await settle(tester);
    expect(find.text('Pass'), findsNWidgets(2));
    expect(find.text('Print All Result Cards'), findsOneWidget);
    final ali = tester.getTopLeft(find.text('Ali Raza')).dy;
    final sara = tester.getTopLeft(find.text('Sara Noor')).dy;
    expect(ali, lessThan(sara), reason: 'first position on top');
  });
}
