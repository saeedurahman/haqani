import 'package:intl/intl.dart';

class MoneyUtils {
  const MoneyUtils._();

  static final _format = NumberFormat.decimalPattern('en_US');

  /// Money is stored as whole PKR. Example: 12500 -> "Rs 12,500".
  static String format(int amount) => 'Rs ${_format.format(amount)}';
}
