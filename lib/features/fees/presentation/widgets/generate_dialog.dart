import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_form_dialog.dart';

/// Asks before making vouchers. Returns true to include the annual fee,
/// false to leave it out, or null if cancelled.
class GenerateDialog extends StatefulWidget {
  const GenerateDialog({super.key, required this.className, required this.month});

  final String className;
  final String month;

  static Future<bool?> show(BuildContext context, {required String className, required String month}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => GenerateDialog(className: className, month: month),
    );
  }

  @override
  State<GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<GenerateDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _annual = false;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy').format(DateTime.parse('${widget.month}-01'));
    return AppFormDialog(
      title: 'Generate Vouchers',
      icon: Icons.receipt_long_rounded,
      formKey: _formKey,
      saveLabel: 'Generate',
      onSave: () => Navigator.of(context).pop(_annual),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make fee vouchers for ${widget.className}, $month.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Students who already have a voucher are skipped. Unpaid fee of earlier months is added as previous dues.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _annual,
            onChanged: (v) => setState(() => _annual = v ?? false),
            title: const Text('Also add the annual fee'),
          ),
        ],
      ),
    );
  }
}
