import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/snack.dart';
import '../../domain/report_kind.dart';
import '../../domain/report_models.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_table_view.dart';
import 'report_pdf_page.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.kind});

  final ReportKind kind;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsCubit>(param1: kind)..load(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(kind.label),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            0,
            AppConstants.pagePadding,
            AppConstants.pagePadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.kind.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  ReportFilters(state: state),
                  const SizedBox(height: 18),
                  _Toolbar(state: state),
                  const SizedBox(height: 16),
                  Expanded(child: _content(context, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, ReportsState state) {
    switch (state.status) {
      case ReportsStatus.initial:
      case ReportsStatus.loading:
        return const LoadingView(message: 'Preparing report...');
      case ReportsStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<ReportsCubit>().load(),
        );
      case ReportsStatus.success:
        if (state.classes.isEmpty && state.kind == ReportKind.attendance) {
          return const EmptyState(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            message: 'Add a class in the Classes section first.',
          );
        }
        final doc = state.visibleDocument;
        if (doc == null) {
          return EmptyState(
            icon: Icons.touch_app_rounded,
            title: state.kind == ReportKind.examResults
                ? 'Choose an exam'
                : 'Choose a student',
            message: state.kind == ReportKind.examResults
                ? 'Pick an exam above to see the result sheet.'
                : 'Search for a student above to see the full history.',
          );
        }
        return CustomScrollView(
          slivers: [
            if (doc.subtitle.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    doc.subtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            if (doc.stats.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ReportStats(stats: doc.stats),
                ),
              ),
            for (final table in doc.tables)
              ...reportTableSlivers(context, table),
          ],
        );
    }
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state});

  final ReportsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    final doc = state.visibleDocument;
    final hasSearch = state.document?.tables.any((t) => t.searchable) ?? false;
    return Row(
      children: [
        if (hasSearch)
          AppSearchField(
            width: 340,
            hint: 'Search in this report',
            onChanged: cubit.search,
          ),
        const Spacer(),
        AppButton(
          label: 'Save as CSV',
          icon: Icons.table_chart_rounded,
          style: AppButtonStyle.secondary,
          onPressed: doc == null ? null : () => _saveCsv(context),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: 'PDF / Print',
          icon: Icons.picture_as_pdf_rounded,
          onPressed: doc == null ? null : () => _openPdf(context, doc),
        ),
      ],
    );
  }

  Future<void> _saveCsv(BuildContext context) async {
    final cubit = context.read<ReportsCubit>();
    final bytes = cubit.csvBytes();
    if (bytes == null) return;
    try {
      final saved = await FilePicker.saveFile(
        fileName: cubit.csvFileName(),
        bytes: bytes,
        mimeType: 'text/csv',
        dialogTitle: 'Save report as CSV',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (saved != null && context.mounted) {
        Snack.success(context, 'CSV file saved.');
      }
    } catch (_) {
      if (context.mounted) {
        Snack.error(context, 'The file could not be saved. Please try again.');
      }
    }
  }

  void _openPdf(BuildContext context, ReportDocument document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportPdfPage(
          document: document,
          fileName: '${state.kind.name}_report.pdf',
        ),
      ),
    );
  }
}
