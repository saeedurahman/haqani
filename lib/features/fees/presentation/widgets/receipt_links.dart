import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../domain/fee_models.dart';

/// Opens the receipts of a voucher: one button, or a menu when the voucher
/// was paid in more than one part.
class ReceiptLinks extends StatelessWidget {
  const ReceiptLinks({super.key, required this.payments, required this.onOpen});

  final List<FeePayment> payments;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) return const SizedBox.shrink();
    if (payments.length == 1) {
      final no = payments.single.receiptNo;
      return TextButton.icon(
        onPressed: () => onOpen(no),
        icon: const Icon(Icons.receipt_long_rounded, size: 18),
        label: Text('Receipt $no'),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Show a receipt',
      onSelected: onOpen,
      itemBuilder: (_) => [
        for (final p in payments.reversed)
          PopupMenuItem(
            value: p.receiptNo,
            child: Text(
              'Receipt ${p.receiptNo}  |  ${AppDateUtils.toDisplay(p.date)}  |  ${MoneyUtils.format(p.amount)}',
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              '${payments.length} receipts',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}
