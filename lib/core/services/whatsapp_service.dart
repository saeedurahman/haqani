import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../database/app_database.dart';
import '../utils/phone_utils.dart';

enum WhatsAppResult {
  /// WhatsApp was opened with the message ready. The user still presses Send.
  opened,

  /// No usable phone number is saved for the student's parent.
  noNumber,

  /// WhatsApp could not be opened on this computer.
  failed;

  /// Message to show the user, or null when there is nothing to say.
  String get userMessage => switch (this) {
        opened => 'WhatsApp opened. Check the message and press Send there.',
        noNumber =>
          'No valid phone number is saved for this parent. Add it in the student profile (format 0300-1234567).',
        failed => 'WhatsApp could not be opened. Please check that WhatsApp is installed.',
      };

  bool get isError => this != opened;
}

/// Opens WhatsApp with a ready message for the parent of a student.
/// Nothing is sent automatically.
abstract class WhatsAppService {
  /// [body] is the message text. The greeting and the school name are added.
  Future<WhatsAppResult> sendToParent({required int studentId, required String body});
}

class WhatsAppServiceImpl implements WhatsAppService {
  /// [open] opens a link. Tests pass a fake one.
  WhatsAppServiceImpl(this._db, {Future<bool> Function(Uri)? open})
      : _open = open ?? _openExternal;

  final AppDatabase _db;
  final Future<bool> Function(Uri) _open;

  static Future<bool> _openExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<WhatsAppResult> sendToParent({required int studentId, required String body}) async {
    final row = await _db.studentsDao.byId(studentId);
    if (row == null) return WhatsAppResult.noNumber;

    // The WhatsApp number comes first, then the normal phone number.
    final number = PhoneUtils.toWhatsApp(row.student.whatsappNo) ?? PhoneUtils.toWhatsApp(row.student.phone);
    if (number == null) return WhatsAppResult.noNumber;

    final school = await _schoolName();
    final message = 'Assalam o Alaikum,\n$body\n\n$school';
    final uri = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    try {
      return await _open(uri) ? WhatsAppResult.opened : WhatsAppResult.failed;
    } catch (_) {
      return WhatsAppResult.failed;
    }
  }

  Future<String> _schoolName() async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(AppConstants.settingSchoolName)))
        .getSingleOrNull();
    final value = row?.value;
    return (value == null || value.isEmpty) ? AppStrings.defaultSchoolName : value;
  }
}
