import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/constants/app_constants.dart';
import 'package:haqani/core/database/app_database.dart';
import 'package:haqani/core/services/whatsapp_service.dart';
import 'package:haqani/core/utils/whatsapp_messages.dart';

void main() {
  late AppDatabase db;
  late List<Uri> opened;
  late bool launchResult;
  late bool launchThrows;
  late WhatsAppServiceImpl service;

  Future<int> add({String phone = '', String whatsapp = ''}) {
    return db.into(db.students).insert(StudentsCompanion.insert(
          admissionNo: '${DateTime.now().microsecondsSinceEpoch}',
          name: 'Ali',
          phone: Value(phone),
          whatsappNo: Value(whatsapp),
        ));
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    opened = [];
    launchResult = true;
    launchThrows = false;
    service = WhatsAppServiceImpl(db, open: (uri) async {
      if (launchThrows) throw Exception('no app');
      opened.add(uri);
      return launchResult;
    });
  });

  tearDown(() => db.close());

  group('WhatsAppService', () {
    test('opens wa.me with the 92 number and the encoded message', () async {
      final id = await add(whatsapp: '0300-1234567');

      final result = await service.sendToParent(studentId: id, body: 'Ali was absent & late.');

      expect(result, WhatsAppResult.opened);
      final uri = opened.single;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/923001234567');
      expect(uri.queryParameters['text'], 'Assalam o Alaikum,\nAli was absent & late.\n\nRozatul Atfal');
      expect(uri.toString(), contains('text=Assalam%20o%20Alaikum'), reason: 'spaces are %20, not +');
    });

    test('uses the normal phone when there is no WhatsApp number', () async {
      final id = await add(phone: '03211234567');

      await service.sendToParent(studentId: id, body: 'Hello');

      expect(opened.single.path, '/923211234567');
    });

    test('a wrong WhatsApp number falls back to the phone', () async {
      final id = await add(whatsapp: '123', phone: '0300-7654321');

      await service.sendToParent(studentId: id, body: 'Hello');

      expect(opened.single.path, '/923007654321');
    });

    test('the school name from settings is added to the message', () async {
      await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.settingSchoolName,
            value: 'Test School',
          ));
      final id = await add(phone: '0300-1234567');

      await service.sendToParent(studentId: id, body: 'Hello');

      expect(opened.single.queryParameters['text'], endsWith('\n\nTest School'));
    });

    test('no number, a wrong number and an unknown student give noNumber and open nothing', () async {
      final none = await add();
      final wrong = await add(phone: '12345');

      expect(await service.sendToParent(studentId: none, body: 'x'), WhatsAppResult.noNumber);
      expect(await service.sendToParent(studentId: wrong, body: 'x'), WhatsAppResult.noNumber);
      expect(await service.sendToParent(studentId: 999, body: 'x'), WhatsAppResult.noNumber);
      expect(opened, isEmpty);
    });

    test('a launcher that fails or throws gives failed', () async {
      final id = await add(phone: '0300-1234567');

      launchResult = false;
      expect(await service.sendToParent(studentId: id, body: 'x'), WhatsAppResult.failed);

      launchThrows = true;
      expect(await service.sendToParent(studentId: id, body: 'x'), WhatsAppResult.failed);
    });

    test('result messages', () {
      expect(WhatsAppResult.opened.isError, isFalse);
      expect(WhatsAppResult.noNumber.isError, isTrue);
      expect(WhatsAppResult.noNumber.userMessage, contains('Add it in the student profile'));
      expect(WhatsAppResult.failed.userMessage, contains('installed'));
    });
  });

  group('WhatsAppMessages', () {
    test('absent', () {
      expect(WhatsAppMessages.absent(studentName: 'Ali Raza', date: DateTime(2026, 5, 12)),
          'Ali Raza was absent from school on 12 May 2026. Please let us know the reason.');
    });

    test('attendance month', () {
      expect(
        WhatsAppMessages.attendanceMonth(
          studentName: 'Ali',
          month: DateTime(2026, 5),
          present: 18,
          absent: 2,
          leave: 1,
          percent: 86,
        ),
        'Attendance of Ali for May 2026:\nPresent: 18\nAbsent: 2\nLeave: 1\nAttendance: 86%',
      );
    });

    test('fee receipt for two sisters, with and without a balance', () {
      final withBalance = WhatsAppMessages.feeReceipt(
        studentNames: ['Ayesha', 'Sara'],
        receiptNo: '12',
        date: DateTime(2026, 5, 10),
        received: 3000,
        balance: 500,
      );
      expect(withBalance, contains('Rs 3,000 for Ayesha, Sara on 10 May 2026'));
      expect(withBalance, contains('Receipt No: 12'));
      expect(withBalance, contains('Balance still to pay: Rs 500'));

      expect(
        WhatsAppMessages.feeReceipt(
          studentNames: ['Ali'],
          receiptNo: '1',
          date: DateTime(2026, 5, 10),
          received: 1500,
          balance: 0,
        ),
        contains('No balance is pending'),
      );
    });

    test('fee reminder', () {
      expect(
        WhatsAppMessages.feeReminder(studentName: 'Ali', month: '2026-05', balance: 1000),
        'This is a reminder that the fee of Ali for May 2026 is not fully paid. Balance: Rs 1,000. Please pay it soon.',
      );
    });

    test('result with and without a position', () {
      final ranked = WhatsAppMessages.result(
        studentName: 'Ali',
        examName: 'Annual 2026',
        obtained: 210,
        maxMarks: 250,
        percent: 84,
        grade: 'A+',
        resultText: 'Pass',
        position: 2,
        rankedStudents: 24,
      );
      expect(ranked, 'Result of Ali - Annual 2026:\nMarks: 210 / 250 (84.0%)\nGrade: A+\nPosition: 2 of 24\nResult: Pass');

      final unranked = WhatsAppMessages.result(
        studentName: 'Ali',
        examName: 'Annual',
        obtained: 100,
        maxMarks: 250,
        percent: 40,
        grade: 'D',
        resultText: 'Incomplete',
      );
      expect(unranked, isNot(contains('Position')));
    });

    test('student update only lists what is known', () {
      expect(
        WhatsAppMessages.studentUpdate(studentName: 'Ali', classLabel: 'Class 1 - A', attendancePercent: 92, feeDue: 1500),
        'This is a message about Ali (Class 1 - A).\nAttendance so far: 92%\nFee due: Rs 1,500',
      );
      expect(
        WhatsAppMessages.studentUpdate(studentName: 'Ali', classLabel: 'Class 1', feeDue: 0),
        'This is a message about Ali (Class 1).',
      );
    });
  });
}
