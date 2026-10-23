import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/snack.dart';
import '../cubit/classes_cubit.dart';
import '../cubit/classes_state.dart';
import '../widgets/class_form_dialog.dart';
import '../widgets/classes_list.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClassesCubit>()..load(),
      child: const _ClassesView(),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassesCubit, ClassesState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Classes',
                  subtitle: 'Classes, sections and class teachers',
                  trailing: Row(
                    children: [
                      AppSearchField(
                        hint: 'Search class or section',
                        onChanged: (q) =>
                            context.read<ClassesCubit>().search(q),
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        label: 'Add Class',
                        icon: Icons.add_rounded,
                        onPressed: () => _addClass(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addClass(BuildContext context) async {
    final cubit = context.read<ClassesCubit>();
    final name = await ClassFormDialog.show(context);
    if (name != null) await cubit.addClass(name);
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        switch (state.status) {
          case ClassesStatus.initial:
          case ClassesStatus.loading:
            return const LoadingView();
          case ClassesStatus.failure:
            return ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<ClassesCubit>().load(),
            );
          case ClassesStatus.success:
            return ClassesList(state: state);
        }
      },
    );
  }
}
