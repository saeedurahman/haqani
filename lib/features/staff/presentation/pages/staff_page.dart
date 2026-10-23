import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../cubit/staff_cubit.dart';
import '../cubit/staff_state.dart';
import '../widgets/staff_row.dart';
import 'staff_form_page.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StaffCubit>()..load(),
      child: const _StaffView(),
    );
  }
}

class _StaffView extends StatelessWidget {
  const _StaffView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StaffCubit>();
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
                  title: 'Staff',
                  subtitle: 'Teachers and other staff',
                  trailing: AppButton(
                    label: 'Add Staff',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => _open(context, const StaffFormPage()),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSearchField(
                      width: 420,
                      hint: 'Search by name, designation or phone',
                      onChanged: cubit.search,
                    ),
                    BlocBuilder<StaffCubit, StaffState>(
                      buildWhen: (a, b) => a.includeInactive != b.includeInactive,
                      builder: (context, state) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(value: state.includeInactive, onChanged: cubit.showInactive),
                          const SizedBox(width: 6),
                          const Text('Show staff who left'),
                        ],
                      ),
                    ),
                  ],
                ),
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
  final cubit = context.read<StaffCubit>();
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  await cubit.refresh();
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffCubit, StaffState>(
      builder: (context, state) {
        switch (state.status) {
          case StaffStatus.initial:
          case StaffStatus.loading:
            return const LoadingView();
          case StaffStatus.failure:
            return ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<StaffCubit>().load(),
            );
          case StaffStatus.success:
            if (state.staff.isEmpty) {
              if (state.hasFilter) {
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No staff found',
                  message: 'Try a different name, designation or phone.',
                );
              }
              return EmptyState(
                icon: Icons.badge_rounded,
                title: 'No staff yet',
                message: 'Add teachers and other staff here.',
                action: AppButton(
                  label: 'Add Staff',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _open(context, const StaffFormPage()),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: state.staff.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final member = state.staff[i];
                return StaffRow(
                  member: member,
                  onTap: () => _open(context, StaffFormPage(staffId: member.id)),
                );
              },
            );
        }
      },
    );
  }
}
