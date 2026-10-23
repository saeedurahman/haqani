import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../students/domain/student_extras.dart';
import '../../domain/exam_models.dart';

class ExamFormDialog extends StatefulWidget {
  const ExamFormDialog({super.key, required this.classes, this.exam, this.initialClassId});

  final List<ClassOption> classes;

  /// Set when editing.
  final Exam? exam;

  /// Class to select when adding.
  final int? initialClassId;

  static Future<Exam?> show(
    BuildContext context, {
    required List<ClassOption> classes,
    Exam? exam,
    int? initialClassId,
  }) {
    return showDialog<Exam>(
      context: context,
      builder: (_) => ExamFormDialog(classes: classes, exam: exam, initialClassId: initialClassId),
    );
  }

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.exam?.name);
  late int? _classId = widget.exam?.classId ??
      widget.initialClassId ??
      (widget.classes.isEmpty ? null : widget.classes.first.id);
  late DateTime? _date = widget.exam?.date ?? (widget.exam == null ? DateTime.now() : null);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(Exam(
      id: widget.exam?.id ?? 0,
      name: _name.text.trim(),
      classId: _classId ?? 0,
      date: _date,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.exam == null ? 'Create Exam' : 'Edit Exam',
      icon: Icons.edit_note_rounded,
      formKey: _formKey,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Exam name',
            hint: 'Example: Annual 2026',
            controller: _name,
            autofocus: true,
            validator: (v) => Validators.required(v, label: 'Exam name'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Class',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _classId,
            isExpanded: true,
            items: [
              for (final c in widget.classes) DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            validator: (v) => v == null ? 'Choose a class' : null,
            onChanged: (v) => setState(() => _classId = v),
          ),
          const SizedBox(height: 18),
          AppDateField(
            label: 'Exam date',
            value: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
        ],
      ),
    );
  }
}
