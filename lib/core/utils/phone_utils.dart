class PhoneUtils {
  const PhoneUtils._();

  /// Converts a Pakistan number such as `0300-1234567` to `923001234567`
  /// for use in `wa.me` links. Returns null if the number looks wrong.
  static String? toWhatsApp(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0092')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
    if (!digits.startsWith('92') || digits.length != 12) return null;
    return digits;
  }
}
