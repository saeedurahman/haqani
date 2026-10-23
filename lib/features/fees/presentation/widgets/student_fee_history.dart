import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/fee_models.dart';
import 'fee_status_chip.dart';
import 'receipt_links.dart';

/// Every voucher of one student, newest month first.
class StudentFeeHistory extends StatelessWidget {
  const StudentFeeHistory({super.key, required this.history, required this.onReceipt});

  final List<FeeVoucher> history;
  final ValueChanged<String> onReceipt;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Fee history',
      icon: Icons.history_rounded,
      child: history.isEmpty
          ? Text('No vouchers yet.', style: Theme.of(context).textTheme.bodyMedium)
          : Column(
              children: [
                for (final v in history)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(v.forMonth, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${MoneyUtils.format(v.paidAmount)} of ${MoneyUtils.format(v.total)}'
                            '${v.lastPaymentDate == null ? '' : '  (${AppDateUtils.toDisplay(v.lastPaymentDate!)})'}',
                          ),
                        ),
                        FeeStatusChip(voucher: v),
                        SizedBox(
                          width: 150,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ReceiptLinks(payments: v.payments, onOpen: onReceipt),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
