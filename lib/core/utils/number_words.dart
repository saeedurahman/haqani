import 'package:intl/intl.dart';

class NumberWords {
  const NumberWords._();

  static const _small = [
    'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen',
  ];
  static const _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety',
  ];

  /// 0 to 9999. Example: 2018 -> "Two Thousand Eighteen".
  static String of(int n) {
    if (n < 0 || n > 9999) throw RangeError.range(n, 0, 9999, 'n');
    if (n < 20) return _small[n];
    if (n < 100) {
      final rest = n % 10;
      return rest == 0 ? _tens[n ~/ 10] : '${_tens[n ~/ 10]} ${_small[rest]}';
    }
    if (n < 1000) {
      final rest = n % 100;
      final head = '${_small[n ~/ 100]} Hundred';
      return rest == 0 ? head : '$head ${of(rest)}';
    }
    final rest = n % 1000;
    final head = '${_small[n ~/ 1000]} Thousand';
    return rest == 0 ? head : '$head ${of(rest)}';
  }

  /// Example: 5 March 2018 -> "Five March Two Thousand Eighteen".
  static String dateInWords(DateTime date) {
    final month = DateFormat('MMMM', 'en_US').format(date);
    return '${of(date.day)} $month ${of(date.year)}';
  }
}
