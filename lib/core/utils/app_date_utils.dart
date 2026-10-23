import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static final _iso = DateFormat('yyyy-MM-dd');
  static final _display = DateFormat('dd MMM yyyy');
  static final _month = DateFormat('yyyy-MM');
  static final _backupStamp = DateFormat('yyyy-MM-dd_HH-mm');

  static String toIso(DateTime date) => _iso.format(date);
  static String toDisplay(DateTime date) => _display.format(date);
  static String toMonth(DateTime date) => _month.format(date);
  static String backupStamp(DateTime date) => _backupStamp.format(date);

  static DateTime? tryParseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
