import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../cubit/admissions_cubit.dart';
import '../cubit/admissions_state.dart';
import '../widgets/admission_row.dart';
import '../widgets/admissions_filter_bar.dart';
import 'admission_form_page.dart';
import 'leaving_certificate_page.dart';

class AdmissionsPage extends StatelessWidget {
  const AdmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdmissionsCubit>()..load(),
      child: const _AdmissionsView(),
    );
  }
}

class _AdmissionsView extends StatelessWidget {
  const _AdmissionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Admissions',
                  subtitle: 'New admissions and leaving certificates',
                  trailing: AppButton(
                    label: 'New Admission',
                    icon: Icons.how_to_reg_rounded,
                    onPressed: () => _open(context, const AdmissionFormPage()),
                  ),
                ),
                const SizedBox(height: 24),
                const AdmissionsFilterBar(),
                const SizedBox(height: 24),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a page, then refreshes the list when it comes back.
Future<void> _open(BuildContext context, Widget page) async {
  final cubit = context.read<AdmissionsCubit>();
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  await cubit.refresh();
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdmissionsCubit, AdmissionsState>(
      builder: (context, state) {
        switch (state.status) {
          case AdmissionsStatus.initial:
          case AdmissionsStatus.loading:
            return const LoadingView();
          case AdmissionsStatus.failure:
            return ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<AdmissionsCubit>().load(),
            );
          case AdmissionsStatus.success:
            if (state.students.isEmpty) return _Empty(hasFilter: state.hasFilter);
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: state.students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final student = state.students[i];
                return AdmissionRow(
                  student: student,
                  onCertificate: () => _open(
                    context,
                    LeavingCertificatePage(studentId: student.id),
                  ),
                );
              },
            );
        }
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    if (hasFilter) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No admissions found',
        message: 'Try a different name, number or dates.',
      );
    }
    return EmptyState(
      icon: Icons.how_to_reg_rounded,
      title: 'No admissions yet',
      message: 'Start with New Admission. The admission number is given automatically.',
      action: AppButton(
        label: 'New Admission',
        icon: Icons.how_to_reg_rounded,
        onPressed: () => _open(context, const AdmissionFormPage()),
      ),
    );
  }
}
