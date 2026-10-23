import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../cubit/student_form_cubit.dart';
import '../cubit/student_form_state.dart';
import '../widgets/student_form_controller.dart';
import '../widgets/student_form_sections.dart';

/// Add a student, or edit one when [studentId] is given.
class StudentFormPage extends StatelessWidget {
  const StudentFormPage({super.key, this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StudentFormCubit>()..load(studentId: studentId),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentFormCubit, StudentFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == StudentFormStatus.saved) {
          Snack.success(context, state.isEditing ? 'Student updated.' : 'Student added.');
          Navigator.of(context).pop(state.savedId);
        } else if (state.status == StudentFormStatus.ready && state.errorMessage != null) {
          Snack.error(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(state.isEditing ? 'Edit Student' : 'Add Student'),
          ),
          body: switch (state.status) {
            StudentFormStatus.initial || StudentFormStatus.loading => const LoadingView(),
            StudentFormStatus.failure => ErrorView(message: state.errorMessage),
            _ => _FormBody(state: state),
          },
        );
      },
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({required this.state});

  final StudentFormState state;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _formKey = GlobalKey<FormState>();
  late final StudentFormController _form = StudentFormController(
    student: widget.state.student,
    suggestedAdmissionNo: widget.state.suggestedAdmissionNo,
  );

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<StudentFormCubit>().save(_form.toStudent());
    } else {
      Snack.error(context, 'Please fix the red fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.state.status == StudentFormStatus.saving;
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            8,
            AppConstants.pagePadding,
            AppConstants.pagePadding,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  PersonalSection(form: _form, onChanged: _refresh),
                  const SizedBox(height: 20),
                  ParentSection(form: _form),
                  const SizedBox(height: 20),
                  SchoolInfoSection(form: _form, classes: widget.state.classes, onChanged: _refresh),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: widget.state.student == null ? 'Save Student' : 'Save Changes',
                      icon: Icons.check_rounded,
                      isLoading: saving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
