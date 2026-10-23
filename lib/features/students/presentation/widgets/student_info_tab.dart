import 'package:flutter/material.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/student.dart';
import '../../domain/student_extras.dart';
import 'documents_section.dart';
import 'info_tile.dart';

String _date(DateTime? d) => d == null ? '' : AppDateUtils.toDisplay(d);

class StudentInfoTab extends StatelessWidget {
  const StudentInfoTab({super.key, required this.student, required this.documents});

  final Student student;
  final List<StudentDocumentItem> documents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Student',
          icon: Icons.person_rounded,
          child: AdaptiveGrid(
            maxColumns: 3,
            minItemWidth: 240,
            children: [
              InfoTile(label: 'Admission No', value: student.admissionNo),
              InfoTile(label: 'Registration No', value: student.registrationNo),
              InfoTile(label: 'Gender', value: student.gender == 'female' ? 'Girl' : 'Boy'),
              InfoTile(label: 'Date of birth', value: _date(student.dob)),
              InfoTile(label: 'Class', value: student.classLabel),
              InfoTile(label: 'Admission date', value: _date(student.admissionDate)),
              InfoTile(label: 'Previous school', value: student.previousSchool),
              InfoTile(label: 'Previous class', value: student.previousClass),
              if (!student.isActive) InfoTile(label: 'Leaving date', value: _date(student.leavingDate)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Parent and contact',
          icon: Icons.family_restroom_rounded,
          child: AdaptiveGrid(
            maxColumns: 3,
            minItemWidth: 240,
            children: [
              InfoTile(label: 'Father name', value: student.fatherName),
              InfoTile(label: 'Father CNIC', value: student.fatherCnic),
              InfoTile(label: 'Father profession', value: student.fatherProfession),
              InfoTile(label: 'Father education', value: student.fatherEducation),
              InfoTile(label: 'Phone', value: student.phone),
              InfoTile(label: 'WhatsApp', value: student.whatsappNo),
              InfoTile(label: 'Address', value: student.address),
              InfoTile(label: 'Notes', value: student.notes),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DocumentsSection(documents: documents),
      ],
    );
  }
}
