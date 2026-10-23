import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../../students/presentation/widgets/student_form_controller.dart';
import '../../../students/presentation/widgets/student_form_sections.dart';
import '../cubit/admission_form_cubit.dart';
import '../cubit/admission_form_state.dart';

class AdmissionFormPage extends StatelessWidget {
  const AdmissionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdmissionFormCubit>()..load(),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdmissionFormCubit, AdmissionFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == AdmissionFormStatus.saved) {
          Snack.success(
            context,
            'Admission done. Admission No ${state.admitted!.admissionNo}.',
          );
          Navigator.of(context).pop();
        } else if (state.status == AdmissionFormStatus.ready && state.errorMessage != null) {
          Snack.error(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('New Admission'),
          ),
          body: switch (state.status) {
            AdmissionFormStatus.initial || AdmissionFormStatus.loading => const LoadingView(),
            AdmissionFormStatus.failure => ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<AdmissionFormCubit>().load(),
              ),
            _ => _FormBody(state: state),
          },
        );
      },
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({required this.state});

  final AdmissionFormState state;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _formKey = GlobalKey<FormState>();
  late final StudentFormController _form = StudentFormController(
    suggestedAdmissionNo: widget.state.nextAdmissionNo,
  );

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _save() {
    if (_formKey.currentState!.validate()) {
      context.read<AdmissionFormCubit>().admit(_form.toStudent());
    } else {
      Snack.error(context, 'Please fix the red fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.state.status == AdmissionFormStatus.saving;
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
                  PersonalSection(form: _form, onChanged: _refresh, autoAdmissionNo: true),
                  const SizedBox(height: 20),
                  ParentSection(form: _form),
                  const SizedBox(height: 20),
                  SchoolInfoSection(
                    form: _form,
                    classes: widget.state.classes,
                    onChanged: _refresh,
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Admit Student',
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
