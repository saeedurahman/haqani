import 'package:flutter/services.dart';

/// Makes the app fonts known to Flutter's text engine, as the real app does
/// through pubspec.yaml. Needed by tests that draw Urdu text.
Future<void> loadAppFonts() async {
  for (final entry in {
    'Inter': ['Inter-400', 'Inter-700'],
    'NotoNaskhArabic': ['NotoNaskhArabic-400', 'NotoNaskhArabic-700'],
  }.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
}
