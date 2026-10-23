import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/app.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';

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

  testWidgets('shows side navigation and dashboard, and switches section',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SchoolApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Welcome to Rozatul Atfal'), findsOneWidget);
    expect(find.text('Add Student'), findsOneWidget);
    expect(find.text('Mark Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
    expect(find.text('No backup yet'), findsOneWidget);

    await tester.tap(find.text('Reports').first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('This section is coming soon.'), findsOneWidget);
  });
}
