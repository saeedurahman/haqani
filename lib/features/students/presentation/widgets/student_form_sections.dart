import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/student_extras.dart';
import 'student_form_controller.dart';

const _gridWidth = 320.0;

class PersonalSection extends StatelessWidget {
  const PersonalSection({
    super.key,
    required this.form,
    required this.onChanged,
    this.autoAdmissionNo = false,
  });

  final StudentFormController form;
  final VoidCallback onChanged;

  /// Admissions: the number is given automatically and cannot be typed.
  final bool autoAdmissionNo;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Student',
      icon: Icons.person_rounded,
      child: AdaptiveGrid(
        maxColumns: 2,
        minItemWidth: _gridWidth,
        children: [
          AppTextField(
            label: autoAdmissionNo ? 'Admission No' : 'Admission No *',
            controller: form.admissionNo,
            readOnly: autoAdmissionNo,
            helper: autoAdmissionNo ? 'Given automatically when you save' : null,
            validator: autoAdmissionNo
                ? null
                : (v) => Validators.required(v, label: 'Admission No'),
          ),
          AppTextField(label: 'Registration No', controller: form.registrationNo),
          AppTextField(
            label: 'Student name *',
            controller: form.name,
            validator: (v) => Validators.required(v, label: 'Student name'),
          ),
          AppTextField(label: 'Father name', controller: form.fatherName),
          AppDateField(
            label: 'Date of birth',
            value: form.dob,
            lastDate: DateTime.now(),
            onChanged: (d) {
              form.dob = d;
              onChanged();
            },
          ),
          _GenderPicker(form: form, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.form, required this.onChanged});

  final StudentFormController form;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'male', label: Text('Boy'), icon: Icon(Icons.male_rounded)),
            ButtonSegment(value: 'female', label: Text('Girl'), icon: Icon(Icons.female_rounded)),
          ],
          selected: {form.gender},
          onSelectionChanged: (s) {
            form.gender = s.first;
            onChanged();
          },
        ),
      ],
    );
  }
}

class ParentSection extends StatelessWidget {
  const ParentSection({super.key, required this.form});

  final StudentFormController form;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Parent and contact',
      icon: Icons.family_restroom_rounded,
      child: AdaptiveGrid(
        maxColumns: 2,
        minItemWidth: _gridWidth,
        children: [
          AppTextField(
            label: 'Father CNIC',
            hint: '12345-1234567-1',
            controller: form.fatherCnic,
            validator: Validators.cnic,
          ),
          AppTextField(label: 'Father profession', controller: form.fatherProfession),
          AppTextField(label: 'Father education', controller: form.fatherEducation),
          AppTextField(
            label: 'Phone',
            hint: '0300-1234567',
            controller: form.phone,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          AppTextField(
            label: 'WhatsApp number',
            hint: '0300-1234567',
            controller: form.whatsappNo,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          AppTextField(label: 'Address', controller: form.address),
        ],
      ),
    );
  }
}

class SchoolInfoSection extends StatelessWidget {
  const SchoolInfoSection({
    super.key,
    required this.form,
    required this.classes,
    required this.onChanged,
  });

  final StudentFormController form;
  final List<ClassOption> classes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = classes.where((c) => c.id == form.classId).firstOrNull;
    final sections = selected?.sections ?? const <SectionOption>[];
    return SectionCard(
      title: 'School',
      icon: Icons.school_rounded,
      child: AdaptiveGrid(
        maxColumns: 2,
        minItemWidth: _gridWidth,
        children: [
          _Dropdown(
            label: 'Class',
            value: selected?.id,
            emptyLabel: 'No class',
            items: {for (final c in classes) c.id: c.name},
            onChanged: (id) {
              form.classId = id;
              form.sectionId = null;
              onChanged();
            },
          ),
          _Dropdown(
            key: ValueKey('section-${form.classId}'),
            label: 'Section',
            value: sections.any((s) => s.id == form.sectionId) ? form.sectionId : null,
            emptyLabel: 'No section',
            items: {for (final s in sections) s.id: s.name},
            onChanged: (id) {
              form.sectionId = id;
              onChanged();
            },
          ),
          AppDateField(
            label: 'Admission date',
            value: form.admissionDate,
            onChanged: (d) {
              form.admissionDate = d;
              onChanged();
            },
          ),
          AppTextField(label: 'Previous school', controller: form.previousSchool),
          AppTextField(label: 'Previous class', controller: form.previousClass),
          AppTextField(label: 'Notes', controller: form.notes),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    super.key,
    required this.label,
    required this.value,
    required this.emptyLabel,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final String emptyLabel;
  final Map<int, String> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          initialValue: value,
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(value: null, child: Text(emptyLabel)),
            for (final e in items.entries)
              DropdownMenuItem<int?>(value: e.key, child: Text(e.value)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
