import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Whole-rupee input. Calls [onChanged] with 0 when the box is empty.
class MoneyField extends StatefulWidget {
  const MoneyField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.width = 140,
    this.enabled = true,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final double width;
  final bool enabled;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final _controller = TextEditingController(text: _text(widget.value));

  String _text(int v) => v == 0 ? '' : '$v';

  @override
  void didUpdateWidget(MoneyField old) {
    super.didUpdateWidget(old);
    // Follow changes made by the cubit (for example a clamped amount).
    final typed = int.tryParse(_controller.text) ?? 0;
    if (typed != widget.value) {
      _controller.value = TextEditingValue(
        text: _text(widget.value),
        selection: TextSelection.collapsed(offset: _text(widget.value).length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            decoration: const InputDecoration(
              hintText: '0',
              prefixText: 'Rs ',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onChanged: (text) => widget.onChanged(int.tryParse(text) ?? 0),
          ),
        ],
      ),
    );
  }
}
