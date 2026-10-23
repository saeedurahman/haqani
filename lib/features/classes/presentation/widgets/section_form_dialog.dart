import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/school_class.dart';

class SectionFormResult {
  const SectionFormResult({required this.name, this.teacherId});

  final String name;
  final int? teacherId;
}

class SectionFormDialog extends StatefulWidget {
  const SectionFormDialog({super.key, required this.teachers, this.section});

  final List<TeacherOption> teachers;

  /// Set when editing.
  final SchoolSection? section;

  static Future<SectionFormResult?> show(
    BuildContext context, {
    required List<TeacherOption> teachers,
    SchoolSection? section,
  }) {
    return showDialog<SectionFormResult>(
      context: context,
      builder: (_) => SectionFormDialog(teachers: teachers, section: section),
    );
  }

  @override
  State<SectionFormDialog> createState() => _SectionFormDialogState();
}

class _SectionFormDialogState extends State<SectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.section?.name);
  late int? _teacherId = widget.section?.classTeacherId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Keeps the current teacher in the list even if they are no longer active.
  List<TeacherOption> get _options {
    final section = widget.section;
    final id = section?.classTeacherId;
    if (id == null || widget.teachers.any((t) => t.id == id)) {
      return widget.teachers;
    }
    return [
      TeacherOption(id: id, name: section?.classTeacherName ?? 'Teacher'),
      ...widget.teachers,
    ];
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(
        context,
      ).pop(SectionFormResult(name: _name.text.trim(), teacherId: _teacherId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.section == null ? 'Add Section' : 'Edit Section',
      icon: Icons.groups_rounded,
      formKey: _formKey,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Section name',
            hint: 'Example: A',
            controller: _name,
            autofocus: true,
            validator: (v) => Validators.required(v, label: 'Section name'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Class teacher (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            initialValue: _teacherId,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('No class teacher'),
              ),
              for (final t in _options)
                DropdownMenuItem<int?>(value: t.id, child: Text(t.name)),
            ],
            onChanged: (value) => setState(() => _teacherId = value),
          ),
          if (widget.teachers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'No teachers yet. Add teachers in the Staff section.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
