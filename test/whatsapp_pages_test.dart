import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/di/injection.dart';
import 'package:haqani/core/services/whatsapp_service.dart';
import 'package:haqani/core/theme/app_theme.dart';
import 'package:haqani/features/attendance/presentation/pages/attendance_page.dart';
import 'package:haqani/features/students/presentation/pages/students_flow.dart';

import 'support/fake_whatsapp.dart';

void main() {
  late AppDatabase db;
  late FakeWhatsAppService whatsApp;

  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final w in [400, 500, 600, 700, 800]) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await loader.load();
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(database: db);
    whatsApp = FakeWhatsAppService();
    getIt.unregister<WhatsAppService>();
    getIt.registerSingleton<WhatsAppService>(whatsApp);
  });

  tearDown(() async {
    await db.close();
    await GetIt.instance.reset();
  });

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: page)));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
  }

  testWidgets('attendance: the WhatsApp button appears only for an absent student and opens WhatsApp',
      (tester) async {
    await tester.runAsync(() async {
      final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
      for (final (no, name) in [('1', 'Ali Raza'), ('2', 'Sara Noor')]) {
        await db.into(db.students).insert(
              StudentsCompanion.insert(admissionNo: no, name: name, classId: Value(c)),
            );
      }
    });
    await pump(tester, const AttendancePage());
    expect(find.byTooltip('Tell the parent on WhatsApp'), findsNothing);

    // The first "Absent" is the count box, then one button per student.
    await tester.tap(find.text('Absent').at(2));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Tell the parent on WhatsApp'), findsOneWidget);

    await tester.tap(find.byTooltip('Tell the parent on WhatsApp'));
    await settle(tester);

    expect(whatsApp.sent.single.body, contains('Sara Noor was absent from school on'));
    expect(find.textContaining('WhatsApp opened'), findsOneWidget);
  });

  testWidgets('attendance: a parent without a number gets a clear message', (tester) async {
    whatsApp.result = WhatsAppResult.noNumber;
    await tester.runAsync(() async {
      final c = await db.into(db.schoolClasses).insert(SchoolClassesCompanion.insert(name: 'Class 1'));
      await db.into(db.students).insert(
            StudentsCompanion.insert(admissionNo: '1', name: 'Ali Raza', classId: Value(c)),
          );
    });
    await pump(tester, const AttendancePage());

    await tester.tap(find.text('Absent').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tell the parent on WhatsApp'));
    await settle(tester);

    expect(find.textContaining('No valid phone number is saved'), findsOneWidget);
  });

  testWidgets('student page: WhatsApp button sends a message about the student', (tester) async {
    await tester.runAsync(() async {
      await db.into(db.students).insert(
            StudentsCompanion.insert(admissionNo: '1', name: 'Ali Raza'),
          );
    });
    await pump(tester, const StudentsFlow());

    await tester.tap(find.text('Ali Raza'));
    await settle(tester);
    await tester.tap(find.text('WhatsApp').first);
    await settle(tester);

    expect(whatsApp.sent.single.studentId, 1);
    expect(whatsApp.sent.single.body, contains('This is a message about Ali Raza'));
    expect(find.textContaining('WhatsApp opened'), findsOneWidget);
  });
}
