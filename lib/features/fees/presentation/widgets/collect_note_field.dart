import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';

/// Optional note for the receipt. Give it a new key to clear it.
class CollectNoteField extends StatefulWidget {
  const CollectNoteField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<CollectNoteField> createState() => _CollectNoteFieldState();
}

class _CollectNoteFieldState extends State<CollectNoteField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Note (optional)',
      hint: 'For example: paid by cheque',
      icon: Icons.sticky_note_2_outlined,
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}
