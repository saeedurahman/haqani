import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../cubit/fee_structure_cubit.dart';
import '../cubit/fee_structure_state.dart';
import '../widgets/fee_structure_card.dart';

class FeeStructureTab extends StatelessWidget {
  const FeeStructureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeeStructureCubit>()..load(),
      child: BlocConsumer<FeeStructureCubit, FeeStructureState>(
        listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
        listener: (context, state) {
          if (state.feedbackIsError) {
            Snack.error(context, state.feedback!);
          } else {
            Snack.success(context, state.feedback!);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case FeeStructureStatus.initial:
            case FeeStructureStatus.loading:
              return const LoadingView();
            case FeeStructureStatus.failure:
              return ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<FeeStructureCubit>().load(),
              );
            case FeeStructureStatus.success:
              if (state.fees.isEmpty) {
                return const EmptyState(
                  icon: Icons.class_rounded,
                  title: 'No classes yet',
                  message: 'Add a class in the Classes section, then set its fee here.',
                );
              }
              final cubit = context.read<FeeStructureCubit>();
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.fees.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final fee = state.fees[i];
                  return FeeStructureCard(
                    key: ValueKey(fee.classId),
                    fee: fee,
                    onSave: (m, a, ad) =>
                        cubit.save(fee.classId, monthly: m, annual: a, admission: ad),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
