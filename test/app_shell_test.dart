import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/app.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/features/admissions/presentation/pages/admissions_flow.dart';
import 'package:haqani/features/attendance/presentation/pages/attendance_page.dart';
import 'package:haqani/features/backup/presentation/pages/backup_page.dart';
import 'package:haqani/features/classes/presentation/pages/classes_page.dart';
import 'package:haqani/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:haqani/features/exams/presentation/pages/exams_flow.dart';
import 'package:haqani/features/fees/presentation/pages/fees_flow.dart';
import 'package:haqani/features/reports/presentation/pages/reports_flow.dart';
import 'package:haqani/features/settings/presentation/pages/settings_page.dart';
import 'package:haqani/features/staff/presentation/pages/staff_flow.dart';
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

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SchoolApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('opens on the dashboard with the daily actions', (tester) async {
    await pumpApp(tester);

    expect(find.text('Welcome to Rozatul Atfal'), findsOneWidget);
    expect(find.text('Add Student'), findsOneWidget);
    expect(find.text('Mark Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('No backup yet'), findsOneWidget);
  });

  testWidgets('every menu item opens its own page', (tester) async {
    await pumpApp(tester);

    final pages = <String, Type>{
      'Students': StudentsFlow,
      'Admissions': AdmissionsFlow,
      'Attendance': AttendancePage,
      'Classes': ClassesPage,
      'Fees': FeesFlow,
      'Staff': StaffFlow,
      'Exams': ExamsFlow,
      'Reports': ReportsFlow,
      'Backup': BackupPage,
      'Settings': SettingsPage,
      'Dashboard': DashboardPage,
    };
    for (final entry in pages.entries) {
      await tester.tap(find.text(entry.key).first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(entry.value), findsOneWidget, reason: entry.key);
    }
  });

  testWidgets('the dashboard quick actions open the matching pages', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Mark Attendance'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AttendancePage), findsOneWidget);

    await tester.tap(find.text('Dashboard').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Collect Fee'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FeesFlow), findsOneWidget);
  });
}
