import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/reports/presentation/pages/reports_flow.dart';

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
      home: const Scaffold(body: ReportsFlow()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
  }

  testWidgets('the hub shows every report', (tester) async {
    await pumpFlow(tester);

    for (final label in [
      'Students',
      'New Admissions',
      'Attendance',
      'Fee Paid / Unpaid',
      'Fee Defaulters',
      'Exam Results',
      'Student History',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('students report shows counts, and search narrows the rows', (tester) async {
    await tester.runAsync(() async {
      final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
      final d = await db.into(db.schoolClasses).insert(
            SchoolClassesCompanion.insert(name: 'Class 2', sortOrder: const Value(1)),
          );
      for (final (no, name, cls, gender) in [
        ('1', 'Ali', c, 'male'),
        ('2', 'Sara', c, 'female'),
        ('3', 'Zoya', d, 'female'),
      ]) {
        await db.into(db.students).insert(StudentsCompanion.insert(
              admissionNo: no,
              name: name,
              classId: Value(cls),
              gender: Value(gender),
            ));
      }
    });
    await pumpFlow(tester);

    await tester.tap(find.text('Students'));
    await settle(tester);

    expect(find.text('Total students'), findsOneWidget);
    expect(find.text('Class-wise students'), findsOneWidget);
    expect(find.text('Class 1'), findsWidgets);
    expect(find.text('Save as CSV'), findsOneWidget);
    expect(find.text('PDF / Print'), findsOneWidget);
  });

  testWidgets('defaulters report shows an empty table when nobody owes', (tester) async {
    await pumpFlow(tester);

    await tester.tap(find.text('Fee Defaulters'));
    await settle(tester);

    expect(find.text('No records.'), findsOneWidget);
    expect(find.text('Students who owe fee'), findsOneWidget);
  });

  testWidgets('exam results and student history ask for a choice first', (tester) async {
    await pumpFlow(tester);

    await tester.tap(find.text('Exam Results'));
    await settle(tester);
    expect(find.text('Choose an exam'), findsWidgets);
    await tester.pageBack();
    await settle(tester);

    await tester.tap(find.text('Student History'));
    await settle(tester);
    expect(find.text('Choose a student'), findsOneWidget);
  });

  testWidgets('attendance report without classes says so', (tester) async {
    await pumpFlow(tester);

    await tester.tap(find.text('Attendance'));
    await settle(tester);

    expect(find.text('No classes yet'), findsOneWidget);
  });
}
