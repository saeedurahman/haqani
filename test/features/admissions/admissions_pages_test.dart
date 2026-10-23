import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/admissions/presentation/pages/admissions_flow.dart';

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
      home: const Scaffold(body: AdmissionsFlow()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('empty register, then a new admission gets number 1 automatically',
      (tester) async {
    await pumpFlow(tester);
    expect(find.text('No admissions yet'), findsOneWidget);

    await tester.tap(find.text('New Admission').last);
    await tester.pumpAndSettle();

    // The number is shown but cannot be typed.
    final numberField = tester.widget<TextField>(
      find.descendant(of: find.byType(TextFormField).first, matching: find.byType(TextField)),
    );
    expect(numberField.readOnly, isTrue);
    expect(find.text('Given automatically when you save'), findsOneWidget);

    await tester.ensureVisible(find.text('Admit Student'));
    await tester.tap(find.text('Admit Student'));
    await tester.pumpAndSettle();
    expect(find.text('Please fix the red fields.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Ayesha Khan');
    await tester.ensureVisible(find.text('Admit Student'));
    await tester.tap(find.text('Admit Student'));
    await tester.pumpAndSettle();

    expect(find.text('Admission done. Admission No 1.'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('No. 1'), findsOneWidget);
    expect(find.text('Leaving Certificate'), findsOneWidget);
  });

  testWidgets('search narrows the register and shows the empty search state', (tester) async {
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

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('No admissions found'), findsOneWidget);
  });
}
