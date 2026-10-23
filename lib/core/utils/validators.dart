class Validators {
  const Validators._();

  static final _phone = RegExp(r'^03\d{2}-?\d{7}$');
  static final _cnic = RegExp(r'^\d{5}-\d{7}-\d$');

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  /// Optional phone, format `03xx-xxxxxxx`.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_phone.hasMatch(value.trim())) return 'Use format 0300-1234567';
    return null;
  }

  /// Optional CNIC, format `xxxxx-xxxxxxx-x`.
  static String? cnic(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_cnic.hasMatch(value.trim())) return 'Use format 12345-1234567-1';
    return null;
  }
}
