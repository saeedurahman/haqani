import 'package:intl/intl.dart';

import 'app_date_utils.dart';
import 'money_utils.dart';

/// Text of the WhatsApp messages. Short, simple English.
/// The greeting and school name are added by `WhatsAppService`.
class WhatsAppMessages {
  const WhatsAppMessages._();

  static String absent({required String studentName, required DateTime date}) {
    return '$studentName was absent from school on ${AppDateUtils.toDisplay(date)}. '
        'Please let us know the reason.';
  }

  static String attendanceMonth({
    required String studentName,
    required DateTime month,
    required int present,
    required int absent,
    required int leave,
    required int percent,
  }) {
    return 'Attendance of $studentName for ${DateFormat('MMMM yyyy').format(month)}:\n'
        'Present: $present\nAbsent: $absent\nLeave: $leave\nAttendance: $percent%';
  }

  static String feeReceipt({
    required List<String> studentNames,
    required String receiptNo,
    required DateTime date,
    required int received,
    required int balance,
  }) {
    final names = studentNames.join(', ');
    final lines = [
      'We received fee of ${MoneyUtils.format(received)} for $names on ${AppDateUtils.toDisplay(date)}.',
      'Receipt No: $receiptNo',
      balance > 0 ? 'Balance still to pay: ${MoneyUtils.format(balance)}' : 'No balance is pending. Thank you.',
    ];
    return lines.join('\n');
  }

  static String feeReminder({
    required String studentName,
    required String month,
    required int balance,
  }) {
    final monthName = DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'));
    return 'This is a reminder that the fee of $studentName for $monthName is not fully paid. '
        'Balance: ${MoneyUtils.format(balance)}. Please pay it soon.';
  }

  static String result({
    required String studentName,
    required String examName,
    required int obtained,
    required int maxMarks,
    required double percent,
    required String grade,
    required String resultText,
    int? position,
    int? rankedStudents,
  }) {
    return [
      'Result of $studentName - $examName:',
      'Marks: $obtained / $maxMarks (${percent.toStringAsFixed(1)}%)',
      'Grade: $grade',
      if (position != null) 'Position: $position${rankedStudents == null ? '' : ' of $rankedStudents'}',
      'Result: $resultText',
    ].join('\n');
  }

  static String studentUpdate({
    required String studentName,
    required String classLabel,
    int? attendancePercent,
    int? feeDue,
  }) {
    return [
      'This is a message about $studentName ($classLabel).',
      if (attendancePercent != null) 'Attendance so far: $attendancePercent%',
      if (feeDue != null && feeDue > 0) 'Fee due: ${MoneyUtils.format(feeDue)}',
    ].join('\n');
  }
}
