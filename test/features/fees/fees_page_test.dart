import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/fees/presentation/pages/fees_flow.dart';

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
      home: const Scaffold(body: FeesFlow()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pumpAndSettle();
  }

  Future<int> seedClass() async {
    final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
    for (final (no, name) in [('1', 'Ali Raza'), ('2', 'Sara Raza')]) {
      await db.into(db.students).insert(StudentsCompanion.insert(
            admissionNo: no,
            name: name,
            classId: Value(c),
            fatherName: const Value('Raza Ahmed'),
            fatherCnic: const Value('12345-1234567-1'),
          ));
    }
    return c;
  }

  testWidgets('collect tab asks who is paying, and says when nobody is found', (tester) async {
    await pumpFlow(tester);
    expect(find.text('Who is paying?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await settle(tester);

    expect(find.text('No students found'), findsOneWidget);
  });

  testWidgets('set the fee, generate vouchers, then collect for two sisters', (tester) async {
    await tester.runAsync(seedClass);
    await pumpFlow(tester);

    // 1. Fee structure.
    await tester.tap(find.text('Fee Structure'));
    await tester.pumpAndSettle();
    await settle(tester);
    expect(find.text('Fee not set yet'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Fees saved for Class 1.'), findsOneWidget);
    expect(find.text('Fee is set'), findsOneWidget);

    // 2. Generate vouchers.
    await tester.tap(find.text('Vouchers'));
    await tester.pumpAndSettle();
    await settle(tester);
    expect(find.text('No vouchers for this month'), findsOneWidget);
    await tester.tap(find.text('Generate Vouchers').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate').last);
    await settle(tester);
    expect(find.text('2 vouchers created.'), findsOneWidget);
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(find.text('Rs 3,000'), findsWidgets);
    expect(find.text('Unpaid (2)'), findsOneWidget);

    // 3. Collect: finding one sister shows both.
    await tester.tap(find.text('Collect Fee'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ali');
    await settle(tester);
    await tester.tap(find.text('Ali Raza'));
    await settle(tester);
    expect(find.text('Sara Raza'), findsOneWidget);
    expect(find.text('Brothers and sisters are listed below. Tick who is paying today.'), findsOneWidget);
    expect(find.text('Rs 3,000'), findsWidgets, reason: 'total to receive');
  });
}
