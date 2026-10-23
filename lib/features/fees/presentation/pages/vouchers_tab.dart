import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/month_switcher.dart';
import '../../../../core/widgets/snack.dart';
import '../../../attendance/presentation/widgets/class_section_picker.dart';
import '../../domain/fee_models.dart';
import '../cubit/vouchers_cubit.dart';
import '../cubit/vouchers_state.dart';
import '../widgets/generate_dialog.dart';
import '../widgets/voucher_row.dart';
import 'receipt_page.dart';

class VouchersTab extends StatelessWidget {
  const VouchersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VouchersCubit>()..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VouchersCubit>();
    return BlocConsumer<VouchersCubit, VouchersState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        final month = DateTime.parse('${state.month}-01');
        final now = DateTime.now();
        final furthest = DateTime(now.year, now.month + 1);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                ClassSectionPicker(
                  classes: state.classes,
                  classId: state.classId,
                  sectionId: state.sectionId,
                  onClassChanged: cubit.selectClass,
                  onSectionChanged: cubit.selectSection,
                ),
                MonthSwitcher(
                  month: month,
                  onMove: cubit.moveMonth,
                  canGoNext: month.isBefore(furthest),
                ),
                AppButton(
                  label: 'Generate Vouchers',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: state.isGenerating,
                  onPressed: state.classId == null ? null : () => _generate(context, state),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _content(context, state)),
          ],
        );
      },
    );
  }

  Future<void> _generate(BuildContext context, VouchersState state) async {
    final cubit = context.read<VouchersCubit>();
    final annual = await GenerateDialog.show(
      context,
      className: state.selectedClass?.name ?? '',
      month: state.month,
    );
    if (annual != null) await cubit.generate(includeAnnualFee: annual);
  }

  Widget _content(BuildContext context, VouchersState state) {
    switch (state.status) {
      case VouchersStatus.initial:
      case VouchersStatus.loading:
        return const LoadingView();
      case VouchersStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<VouchersCubit>().load(),
        );
      case VouchersStatus.success:
        if (state.classes.isEmpty) {
          return const EmptyState(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            message: 'Add a class in the Classes section first.',
          );
        }
        if (state.vouchers.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No vouchers for this month',
            message: 'Press Generate Vouchers to make them for the whole class.',
          );
        }
        return _List(state: state);
    }
  }
}

class _List extends StatelessWidget {
  const _List({required this.state});

  final VouchersState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VouchersCubit>();
    final visible = state.visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoucherTotals(
          billed: state.totalBilled,
          collected: state.totalCollected,
          pending: state.totalPending,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (label, status) in const [
              ('All', null),
              ('Unpaid', FeeStatus.unpaid),
              ('Partial', FeeStatus.partial),
              ('Paid', FeeStatus.paid),
            ])
              ChoiceChip(
                label: Text('$label (${state.count(status)})'),
                selected: state.statusFilter == status,
                onSelected: (_) => cubit.filterByStatus(status),
              ),
            AppSearchField(width: 300, hint: 'Search student', onChanged: cubit.search),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No vouchers found',
                  message: 'Try another filter or name.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => VoucherRow(
                    voucher: visible[i],
                    onRemind: () => cubit.remind(visible[i]),
                    onReceipt: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => ReceiptPage(receiptNo: visible[i].receiptNo),
                    )),
                  ),
                ),
        ),
      ],
    );
  }
}
