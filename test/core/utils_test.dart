import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/utils/money_utils.dart';
import 'package:haqani/core/utils/phone_utils.dart';
import 'package:haqani/core/utils/validators.dart';

void main() {
  group('PhoneUtils.toWhatsApp', () {
    test('converts 03xx numbers to 92 format', () {
      expect(PhoneUtils.toWhatsApp('0300-1234567'), '923001234567');
      expect(PhoneUtils.toWhatsApp('03211234567'), '923211234567');
    });

    test('keeps numbers that already start with 92', () {
      expect(PhoneUtils.toWhatsApp('+92 300 1234567'), '923001234567');
    });

    test('returns null for wrong numbers', () {
      expect(PhoneUtils.toWhatsApp('12345'), isNull);
    });
  });

  group('Validators', () {
    test('required', () {
      expect(Validators.required('  ', label: 'Name'), 'Name is required');
      expect(Validators.required('Ali'), isNull);
    });

    test('phone is optional but must match 03xx-xxxxxxx', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('0300-1234567'), isNull);
      expect(Validators.phone('123'), isNotNull);
    });

    test('cnic is optional but must match xxxxx-xxxxxxx-x', () {
      expect(Validators.cnic(null), isNull);
      expect(Validators.cnic('12345-1234567-1'), isNull);
      expect(Validators.cnic('1234512345671'), isNotNull);
    });
  });

  test('MoneyUtils formats whole rupees with separators', () {
    expect(MoneyUtils.format(12500), 'Rs 12,500');
    expect(MoneyUtils.format(0), 'Rs 0');
  });
}
