import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/features/fees/domain/fee_models.dart';
import 'package:haqani/features/fees/presentation/widgets/receipt_links.dart';

FeePayment _payment(int id, String no, int amount) => FeePayment(
  id: id,
  receiptNo: no,
  date: DateTime(2026, 5, id),
  amount: amount,
);

Future<List<String>> _pump(
  WidgetTester tester,
  List<FeePayment> payments,
) async {
  final opened = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ReceiptLinks(payments: payments, onOpen: opened.add),
        ),
      ),
    ),
  );
  return opened;
}

void main() {
  testWidgets('shows nothing when nothing was paid', (tester) async {
    await _pump(tester, const []);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('one payment is one button with its receipt number', (
    tester,
  ) async {
    final opened = await _pump(tester, [_payment(1, '12', 500)]);
    await tester.tap(find.text('Receipt 12'));
    expect(opened, ['12']);
  });

  testWidgets('several payments open a menu with every receipt, newest first', (
    tester,
  ) async {
    final opened = await _pump(tester, [
      _payment(1, '4', 600),
      _payment(2, '9', 400),
    ]);
    expect(find.text('2 receipts'), findsOneWidget);

    await tester.tap(find.text('2 receipts'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Receipt 9'), findsOneWidget);
    expect(find.textContaining('Receipt 4'), findsOneWidget);
    expect(
      tester.getTopLeft(find.textContaining('Receipt 9')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Receipt 4')).dy),
    );

    await tester.tap(find.textContaining('Receipt 4'));
    await tester.pumpAndSettle();
    expect(opened, ['4']);
  });
}
