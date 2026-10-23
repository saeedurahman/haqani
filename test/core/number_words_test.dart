import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/utils/number_words.dart';

void main() {
  test('numbers in words', () {
    expect(NumberWords.of(0), 'Zero');
    expect(NumberWords.of(5), 'Five');
    expect(NumberWords.of(13), 'Thirteen');
    expect(NumberWords.of(20), 'Twenty');
    expect(NumberWords.of(31), 'Thirty One');
    expect(NumberWords.of(100), 'One Hundred');
    expect(NumberWords.of(2018), 'Two Thousand Eighteen');
    expect(NumberWords.of(1999), 'One Thousand Nine Hundred Ninety Nine');
    expect(NumberWords.of(2000), 'Two Thousand');
  });

  test('out of range numbers are refused', () {
    expect(() => NumberWords.of(-1), throwsRangeError);
    expect(() => NumberWords.of(10000), throwsRangeError);
  });

  test('date in words', () {
    expect(NumberWords.dateInWords(DateTime(2018, 3, 5)), 'Five March Two Thousand Eighteen');
    expect(NumberWords.dateInWords(DateTime(2015, 12, 31)),
        'Thirty One December Two Thousand Fifteen');
  });
}
