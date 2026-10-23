import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/students/presentation/pages/students_flow.dart';

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

  Future<void> pumpFlow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: StudentsFlow()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('empty list, then add a student through the form', (tester) async {
    await pumpFlow(tester);
    expect(find.text('No students yet'), findsOneWidget);

    await tester.tap(find.text('Add Student').first);
    await tester.pumpAndSettle();
    expect(find.text('Add Student'), findsWidgets);

    // Admission No is pre-filled with 1.
    expect(find.widgetWithText(TextFormField, '1'), findsOneWidget);

    await tester.ensureVisible(find.text('Save Student'));
    await tester.tap(find.text('Save Student'));
    await tester.pumpAndSettle();
    expect(find.text('Student name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Ayesha Khan');
    await tester.pump();
    await tester.ensureVisible(find.text('Save Student'));
    await tester.tap(find.text('Save Student'));
    await tester.pumpAndSettle();

    expect(find.text('Student added.'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
  });

  testWidgets('search narrows the list and shows the empty search state', (tester) async {
    await tester.runAsync(() async {
      for (final (no, name) in [('1', 'Ali Raza'), ('2', 'Sara Noor')]) {
        await db.into(db.students).insert(
              StudentsCompanion.insert(admissionNo: no, name: name),
            );
      }
    });
    await pumpFlow(tester);
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Sara Noor'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'sara');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Ali Raza'), findsNothing);
    expect(find.text('Sara Noor'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('No students found'), findsOneWidget);
  });

  testWidgets('opens a student, shows tabs, and marks as left after confirming',
      (tester) async {
    await tester.runAsync(() async {
      await db.into(db.students).insert(
            StudentsCompanion.insert(admissionNo: '1', name: 'Ali Raza'),
          );
    });
    await pumpFlow(tester);

    await tester.tap(find.text('Ali Raza'));
    await tester.pumpAndSettle();
    for (final tab in ['Info', 'Attendance', 'Fees', 'Results']) {
      expect(find.text(tab), findsOneWidget);
    }

    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();
    expect(find.text('No attendance yet'), findsOneWidget);

    await tester.tap(find.text('Mark as Left'));
    await tester.pumpAndSettle();
    expect(find.text('Mark Ali Raza as left?'), findsOneWidget);

    await tester.tap(find.text('Mark as Left').last);
    await tester.pumpAndSettle();
    expect(find.text('Ali Raza is marked as left.'), findsOneWidget);
    expect(find.text('Make Active'), findsOneWidget);
  });
}
