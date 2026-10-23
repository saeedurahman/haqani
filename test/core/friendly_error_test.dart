import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/widgets/friendly_error.dart';

void main() {
  testWidgets('shows a short message and no technical text', (tester) async {
    await tester.pumpWidget(const FriendlyError());

    expect(find.text('Something went wrong on this screen.'), findsOneWidget);
    expect(find.textContaining('restart the app'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
