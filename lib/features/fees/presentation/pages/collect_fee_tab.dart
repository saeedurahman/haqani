import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/hover_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../../students/presentation/widgets/student_avatar.dart';
import '../cubit/collect_fee_cubit.dart';
import '../cubit/collect_fee_state.dart';
import '../widgets/collect_row_card.dart';
import '../widgets/student_fee_history.dart';
import 'receipt_page.dart';

class CollectFeeTab extends StatelessWidget {
  const CollectFeeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CollectFeeCubit>(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CollectFeeCubit, CollectFeeState>(
          listenWhen: (a, b) =>
              a.feedbackId != b.feedbackId && b.feedback != null,
          listener: (context, state) {
            if (state.feedbackIsError) {
              Snack.error(context, state.feedback!);
            } else {
              Snack.success(context, state.feedback!);
            }
          },
        ),
        BlocListener<CollectFeeCubit, CollectFeeState>(
          listenWhen: (a, b) => a.receipt != b.receipt && b.receipt != null,
          listener: (context, state) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ReceiptPage(receipt: state.receipt),
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<CollectFeeCubit, CollectFeeState>(
        builder: (context, state) {
          if (state.status == CollectFeeStatus.failure) {
            return ErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<CollectFeeCubit>().clearSelection(),
            );
          }
          if (state.selected == null) return _Search(state: state);
          if (state.status == CollectFeeStatus.loading) {
            return const LoadingView();
          }
          return _Selected(state: state);
        },
      ),
    );
  }
}

class _Search extends StatelessWidget {
  const _Search({required this.state});

  final CollectFeeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CollectFeeCubit>();
    final typed = state.query.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          width: 520,
          hint: 'Search student by name, father name or ID',
          onChanged: cubit.search,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: !typed
              ? const EmptyState(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Who is paying?',
                  message: 'Type the name of the student, or the father name. Brothers and sisters are shown together.',
                )
              : state.results.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No students found',
                  message: 'Try a different name or ID.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: state.results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = state.results[i];
                    return HoverCard(
                      onTap: () => cubit.selectStudent(s),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          StudentAvatar(
                            name: s.name,
                            gender: s.gender,
                            size: 42,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontFamilyFallback:
                                            AppTheme.fontFallback,
                                      ),
                                ),
                                Text(
                                  s.fatherName.isEmpty
                                      ? 'ID ${s.admissionNo}'
                                      : 'ID ${s.admissionNo}  |  Father: ${s.fatherName}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            s.classLabel,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Selected extends StatelessWidget {
  const _Selected({required this.state});

  final CollectFeeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CollectFeeCubit>();
    final family = state.rows.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: cubit.clearSelection,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Another student'),
            ),
            const SizedBox(width: 12),
            if (family)
              Text(
                'Brothers and sisters are listed below. Tick who is paying today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Scrollbar(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final row in state.rows) ...[
                  CollectRowCard(
                    key: ValueKey(row.student.id),
                    row: row,
                    showCheckbox: family,
                    onInclude: (v) => cubit.setInclude(row.student.id, v),
                    onPay: (v) => cubit.setPay(row.student.id, v),
                    onMisc: (v) => cubit.setMiscFee(row.student.id, v),
                    onDiscount: (v) => cubit.setDiscount(row.student.id, v),
                    onCreateVoucher: () => cubit.createVoucher(row.student),
                  ),
                  const SizedBox(height: 14),
                ],
                StudentFeeHistory(
                  history: state.history,
                  onReceipt: (no) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReceiptPage(receiptNo: no),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _CollectBar(state: state),
      ],
    );
  }
}

class _CollectBar extends StatelessWidget {
  const _CollectBar({required this.state});

  final CollectFeeState state;

  @override
  Widget build(BuildContext context) {
    final total = state.payTotal;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Text(
            'Total to receive',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 16),
          Text(
            MoneyUtils.format(total),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Receive Fee',
            icon: Icons.payments_rounded,
            isLoading: state.isCollecting,
            onPressed: total > 0
                ? () => context.read<CollectFeeCubit>().collect()
                : null,
          ),
        ],
      ),
    );
  }
}
