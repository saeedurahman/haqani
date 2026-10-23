import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/school_profile.dart';

/// School name, address and phone with a Save button.
class SchoolInfoCard extends StatefulWidget {
  const SchoolInfoCard({
    super.key,
    required this.profile,
    required this.isSaving,
    required this.onSave,
  });

  final SchoolProfile profile;
  final bool isSaving;
  final void Function(String name, String address, String phone) onSave;

  @override
  State<SchoolInfoCard> createState() => _SchoolInfoCardState();
}

class _SchoolInfoCardState extends State<SchoolInfoCard> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _address = TextEditingController(text: widget.profile.address);
  late final _phone = TextEditingController(text: widget.profile.phone);

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_name.text, _address.text, _phone.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'School information',
      icon: Icons.school_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'School name *',
              controller: _name,
              validator: (v) => Validators.required(v, label: 'School name'),
            ),
            const SizedBox(height: 18),
            AppTextField(label: 'Address', controller: _address),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Phone',
              hint: '042-1234567 or 0300-1234567',
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Text(
              'This is shown in the side menu, and printed on receipts, certificates, result cards and reports.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Save',
              icon: Icons.check_rounded,
              isLoading: widget.isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
