import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_words.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/leaving_certificate.dart';

/// Fields the office can change before printing. Every change calls [onChanged].
class CertificateFormPanel extends StatefulWidget {
  const CertificateFormPanel({super.key, required this.initial, required this.onChanged});

  final LeavingCertificate initial;
  final ValueChanged<LeavingCertificate> onChanged;

  @override
  State<CertificateFormPanel> createState() => _CertificateFormPanelState();
}

class _CertificateFormPanelState extends State<CertificateFormPanel> {
  late LeavingCertificate _c = widget.initial;

  late final _admissionNo = TextEditingController(text: _c.admissionNo);
  late final _name = TextEditingController(text: _c.studentName);
  late final _father = TextEditingController(text: _c.fatherName);
  late final _className = TextEditingController(text: _c.className);
  late final _exam = TextEditingController(text: _c.exam);
  late final _promoted = TextEditingController(text: _c.promotedClass);
  late final _attendance = TextEditingController(text: _c.attendance);
  late final _discipline = TextEditingController(text: _c.discipline);

  @override
  void dispose() {
    for (final c in [_admissionNo, _name, _father, _className, _exam, _promoted, _attendance, _discipline]) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(LeavingCertificate next) {
    setState(() => _c = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Admission No',
          controller: _admissionNo,
          onChanged: (v) => _set(_c.copyWith(admissionNo: v)),
        ),
        _gap,
        AppTextField(
          label: 'Student name',
          controller: _name,
          onChanged: (v) => _set(_c.copyWith(studentName: v)),
        ),
        _gap,
        AppTextField(
          label: 'Father name',
          controller: _father,
          onChanged: (v) => _set(_c.copyWith(fatherName: v)),
        ),
        _gap,
        AppDateField(
          label: 'Date of birth',
          value: _c.dob,
          lastDate: DateTime.now(),
          onChanged: (d) => _set(_c.copyWith(dob: () => d)),
        ),
        if (_c.dob != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'In words: ${NumberWords.dateInWords(_c.dob!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        _gap,
        AppDateField(
          label: 'Date of admission',
          value: _c.admissionDate,
          onChanged: (d) => _set(_c.copyWith(admissionDate: () => d)),
        ),
        _gap,
        AppDateField(
          label: 'Attended school from',
          value: _c.attendedFrom,
          onChanged: (d) => _set(_c.copyWith(attendedFrom: () => d)),
        ),
        _gap,
        AppDateField(
          label: 'Attended school to',
          value: _c.attendedTo,
          onChanged: (d) => _set(_c.copyWith(attendedTo: () => d)),
        ),
        _gap,
        AppTextField(
          label: 'Class',
          controller: _className,
          onChanged: (v) => _set(_c.copyWith(className: v)),
        ),
        _gap,
        AppTextField(
          label: 'Last exam passed',
          hint: 'Example: Annual 2026',
          controller: _exam,
          onChanged: (v) => _set(_c.copyWith(exam: v)),
        ),
        _gap,
        AppTextField(
          label: 'Promoted to class',
          controller: _promoted,
          onChanged: (v) => _set(_c.copyWith(promotedClass: v)),
        ),
        _gap,
        const Text(
          'All dues cleared?',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true, label: Text('Yes')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected: {_c.duesCleared},
          onSelectionChanged: (s) => _set(_c.copyWith(duesCleared: s.first)),
        ),
        _gap,
        AppTextField(
          label: 'Attendance',
          hint: 'Example: 92%',
          controller: _attendance,
          onChanged: (v) => _set(_c.copyWith(attendance: v)),
        ),
        _gap,
        AppTextField(
          label: 'Discipline / conduct',
          controller: _discipline,
          onChanged: (v) => _set(_c.copyWith(discipline: v)),
        ),
        _gap,
        AppDateField(
          label: 'Date of issue',
          value: _c.issueDate,
          onChanged: (d) => _set(_c.copyWith(issueDate: () => d)),
        ),
      ],
    );
  }

  static const _gap = SizedBox(height: 18);
}
