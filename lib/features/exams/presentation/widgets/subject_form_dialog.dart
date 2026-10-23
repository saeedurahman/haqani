import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/exam_models.dart';

class SubjectFormResult {
  const SubjectFormResult({required this.name, required this.totalMarks});

  final String name;
  final int totalMarks;
}

class SubjectFormDialog extends StatefulWidget {
  const SubjectFormDialog({super.key, this.subject});

  /// Set when editing.
  final Subject? subject;

  static Future<SubjectFormResult?> show(BuildContext context, {Subject? subject}) {
    return showDialog<SubjectFormResult>(
      context: context,
      builder: (_) => SubjectFormDialog(subject: subject),
    );
  }

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.subject?.name);
  late final _total = TextEditingController(text: '${widget.subject?.totalMarks ?? 100}');

  @override
  void dispose() {
    _name.dispose();
    _total.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SubjectFormResult(name: _name.text.trim(), totalMarks: int.parse(_total.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.subject == null ? 'Add Subject' : 'Edit Subject',
      icon: Icons.menu_book_rounded,
      formKey: _formKey,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Subject name',
            hint: 'Example: English',
            controller: _name,
            autofocus: true,
            validator: (v) => Validators.required(v, label: 'Subject name'),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Total marks',
            controller: _total,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 1) return 'Enter total marks';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
