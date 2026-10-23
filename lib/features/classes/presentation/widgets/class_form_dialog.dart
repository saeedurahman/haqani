import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class ClassFormDialog extends StatefulWidget {
  const ClassFormDialog({super.key, this.initialName});

  final String? initialName;

  /// Returns the class name, or null if cancelled.
  static Future<String?> show(BuildContext context, {String? initialName}) {
    return showDialog<String>(
      context: context,
      builder: (_) => ClassFormDialog(initialName: initialName),
    );
  }

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;
    return AppFormDialog(
      title: isEdit ? 'Edit Class' : 'Add Class',
      icon: Icons.class_rounded,
      formKey: _formKey,
      onSave: _save,
      child: AppTextField(
        label: 'Class name',
        hint: 'Example: Class 1',
        controller: _name,
        autofocus: true,
        validator: (v) => Validators.required(v, label: 'Class name'),
      ),
    );
  }
}
