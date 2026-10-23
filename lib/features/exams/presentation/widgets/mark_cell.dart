import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// One box of the marks grid. Calls [onChanged] with null when emptied.
class MarkCell extends StatefulWidget {
  const MarkCell({
    super.key,
    required this.value,
    required this.totalMarks,
    required this.invalid,
    required this.onChanged,
  });

  final int? value;
  final int totalMarks;
  final bool invalid;
  final ValueChanged<int?> onChanged;

  @override
  State<MarkCell> createState() => _MarkCellState();
}

class _MarkCellState extends State<MarkCell> {
  late final _controller = TextEditingController(text: widget.value?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: widget.invalid ? AppColors.danger : AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: '/${widget.totalMarks}',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        enabledBorder: widget.invalid
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
              )
            : null,
      ),
      onChanged: (text) => widget.onChanged(int.tryParse(text)),
    );
  }
}
