import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/student_extras.dart';
import '../cubit/student_detail_cubit.dart';

class DocumentsSection extends StatelessWidget {
  const DocumentsSection({super.key, required this.documents});

  final List<StudentDocumentItem> documents;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Documents',
      icon: Icons.attach_file_rounded,
      trailing: AppButton(
        label: 'Attach File',
        icon: Icons.upload_file_rounded,
        style: AppButtonStyle.secondary,
        onPressed: () => _attach(context),
      ),
      child: documents.isEmpty
          ? const Text(
              'No documents attached. Use Attach File for B-Form, certificates, photos and so on.',
              style: TextStyle(color: AppColors.textMuted),
            )
          : Column(
              children: [
                for (final doc in documents)
                  _DocumentTile(
                    document: doc,
                    onOpen: () => launchUrl(Uri.file(doc.filePath)),
                    onDelete: () => _delete(context, doc),
                  ),
              ],
            ),
    );
  }

  Future<void> _attach(BuildContext context) async {
    final cubit = context.read<StudentDetailCubit>();
    final picked = await FilePicker.pickFile();
    final path = picked?.path;
    if (path == null || !context.mounted) return;
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _TitleDialog(initialTitle: p.basenameWithoutExtension(path)),
    );
    if (title != null) await cubit.addDocument(title, path);
  }

  Future<void> _delete(BuildContext context, StudentDocumentItem doc) async {
    final cubit = context.read<StudentDetailCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Remove "${doc.title}"?',
      message: 'The attached copy will be deleted.',
      confirmLabel: 'Remove',
    );
    if (ok) await cubit.deleteDocument(doc.id);
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.onOpen, required this.onDelete});

  final StudentDocumentItem document;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.description_rounded, color: AppColors.accent),
      ),
      title: Text(document.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(p.basename(document.filePath), overflow: TextOverflow.ellipsis),
      onTap: onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Open',
            icon: const Icon(Icons.open_in_new_rounded),
            color: AppColors.primary,
            onPressed: onOpen,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.danger,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TitleDialog extends StatefulWidget {
  const _TitleDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Document name',
      icon: Icons.attach_file_rounded,
      formKey: _formKey,
      onSave: () {
        if (_formKey.currentState!.validate()) Navigator.of(context).pop(_title.text.trim());
      },
      child: AppTextField(
        label: 'Name',
        hint: 'Example: B-Form',
        controller: _title,
        autofocus: true,
        validator: (v) => Validators.required(v, label: 'Name'),
      ),
    );
  }
}
