import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/adaptive_grid.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/snack.dart';
import '../../domain/staff_member.dart';
import '../cubit/staff_form_cubit.dart';
import '../cubit/staff_form_state.dart';

/// Add a person, or edit one when [staffId] is given.
class StaffFormPage extends StatelessWidget {
  const StaffFormPage({super.key, this.staffId});

  final int? staffId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StaffFormCubit>()..load(staffId: staffId),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffFormCubit, StaffFormState>(
      listenWhen: (a, b) =>
          a.status != b.status || (a.feedbackId != b.feedbackId && b.feedback != null),
      listener: (context, state) {
        if (state.status == StaffFormStatus.saved) {
          Snack.success(context, state.isEditing ? 'Staff updated.' : 'Staff added.');
          Navigator.of(context).pop();
        } else if (state.status == StaffFormStatus.ready && state.errorMessage != null) {
          Snack.error(context, state.errorMessage!);
        } else if (state.feedback != null) {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(state.isEditing ? 'Edit Staff' : 'Add Staff'),
          ),
          body: switch (state.status) {
            StaffFormStatus.initial || StaffFormStatus.loading => const LoadingView(),
            StaffFormStatus.failure => ErrorView(message: state.errorMessage),
            _ => _FormBody(state: state),
          },
        );
      },
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({required this.state});

  final StaffFormState state;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _formKey = GlobalKey<FormState>();
  late final StaffMember? _original = widget.state.member;
  late final _name = TextEditingController(text: _original?.name);
  late final _father = TextEditingController(text: _original?.fatherName);
  late final _designation = TextEditingController(text: _original?.designation);
  late final _phone = TextEditingController(text: _original?.phone);
  late final _cnic = TextEditingController(text: _original?.cnic);
  late final _salary = TextEditingController(
    text: (_original?.salary ?? 0) == 0 ? '' : '${_original!.salary}',
  );
  late final _address = TextEditingController(text: _original?.address);
  late DateTime? _joining = _original?.joiningDate ?? (_original == null ? DateTime.now() : null);

  @override
  void dispose() {
    for (final c in [_name, _father, _designation, _phone, _cnic, _salary, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      Snack.error(context, 'Please fix the red fields.');
      return;
    }
    context.read<StaffFormCubit>().save(StaffMember(
          id: _original?.id ?? 0,
          name: _name.text,
          fatherName: _father.text,
          designation: _designation.text,
          phone: _phone.text,
          cnic: _cnic.text,
          joiningDate: _joining,
          salary: int.tryParse(_salary.text) ?? 0,
          address: _address.text,
          isActive: _original?.isActive ?? true,
        ));
  }

  Future<void> _toggleActive() async {
    final cubit = context.read<StaffFormCubit>();
    final member = widget.state.member!;
    if (!member.isActive) {
      await cubit.setActive(active: true);
      return;
    }
    final ok = await ConfirmDialog.show(
      context,
      title: 'Mark ${member.name} as left?',
      message: 'This person will be hidden from the main list. All records are kept.',
      confirmLabel: 'Mark as Left',
    );
    if (ok) await cubit.setActive(active: false);
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.state.status == StaffFormStatus.saving;
    final member = widget.state.member;
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
                  SectionCard(
                    title: 'Staff details',
                    icon: Icons.badge_rounded,
                    child: AdaptiveGrid(
                      maxColumns: 2,
                      minItemWidth: 320,
                      children: [
                        AppTextField(
                          label: 'Name *',
                          controller: _name,
                          validator: (v) => Validators.required(v, label: 'Name'),
                        ),
                        AppTextField(label: 'Father name', controller: _father),
                        AppTextField(
                          label: 'Designation',
                          hint: 'Example: Teacher',
                          controller: _designation,
                        ),
                        AppTextField(
                          label: 'Phone',
                          hint: '0300-1234567',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        AppTextField(
                          label: 'CNIC',
                          hint: '12345-1234567-1',
                          controller: _cnic,
                          validator: Validators.cnic,
                        ),
                        AppDateField(
                          label: 'Joining date',
                          value: _joining,
                          onChanged: (d) => setState(() => _joining = d),
                        ),
                        AppTextField(
                          label: 'Monthly salary (Rs)',
                          controller: _salary,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                        AppTextField(label: 'Address', controller: _address),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (member != null)
                        AppButton(
                          label: member.isActive ? 'Mark as Left' : 'Make Active',
                          icon: member.isActive ? Icons.logout_rounded : Icons.restart_alt_rounded,
                          style: member.isActive ? AppButtonStyle.danger : AppButtonStyle.secondary,
                          onPressed: _toggleActive,
                        ),
                      const Spacer(),
                      AppButton(
                        label: member == null ? 'Save Staff' : 'Save Changes',
                        icon: Icons.check_rounded,
                        isLoading: saving,
                        onPressed: _save,
                      ),
                    ],
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
