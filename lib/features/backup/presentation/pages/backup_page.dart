import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/snack.dart';
import '../../domain/backup_models.dart';
import '../cubit/backup_cubit.dart';
import '../cubit/backup_state.dart';
import '../widgets/backup_list_card.dart';
import '../widgets/backup_settings_cards.dart';
import '../widgets/backup_status_card.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BackupCubit>()..load(),
      child: const _BackupView(),
    );
  }
}

class _BackupView extends StatelessWidget {
  const _BackupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupCubit, BackupState>(
      listenWhen: (a, b) =>
          (a.feedbackId != b.feedbackId && b.feedback != null) || (!a.restored && b.restored),
      listener: (context, state) {
        if (state.restored) {
          _showRestored(context);
        } else if (state.feedbackIsError) {
          Snack.error(context, state.feedback!);
        } else {
          Snack.success(context, state.feedback!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                      title: 'Backup',
                      subtitle: 'Keep a safe copy of all school data',
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: _body(context, state)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, BackupState state) {
    switch (state.status) {
      case BackupStatus.initial:
      case BackupStatus.loading:
        return const LoadingView();
      case BackupStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<BackupCubit>().load(),
        );
      case BackupStatus.success:
        final cubit = context.read<BackupCubit>();
        return Stack(
          children: [
            Scrollbar(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  BackupStatusCard(state: state, onBackup: cubit.backupNow),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BackupFolderCard(
                          settings: state.settings!,
                          onChoose: () => _chooseFolder(context),
                          onUseDefault: () => cubit.setFolder(null),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: DriveCard(
                          state: state,
                          onConnect: cubit.connectDrive,
                          onDisconnect: () => _disconnect(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  BackupListCard(
                    state: state,
                    onRestore: (file) => _restore(context, file),
                    onLoadDrive: cubit.loadDriveBackups,
                  ),
                ],
              ),
            ),
            if (state.busy == BackupBusy.restoring) const _RestoringOverlay(),
          ],
        );
    }
  }

  Future<void> _chooseFolder(BuildContext context) async {
    final cubit = context.read<BackupCubit>();
    final path = await FilePicker.getDirectoryPath(dialogTitle: 'Choose the backup folder');
    if (path != null) await cubit.setFolder(path);
  }

  Future<void> _disconnect(BuildContext context) async {
    final cubit = context.read<BackupCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Disconnect Google Drive?',
      message: 'New backups will not be uploaded. Backups already on Drive are not deleted.',
      confirmLabel: 'Disconnect',
    );
    if (ok) await cubit.disconnectDrive();
  }

  Future<void> _restore(BuildContext context, BackupFile file) async {
    final cubit = context.read<BackupCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Restore this backup?',
      message: 'Backup of ${AppDateUtils.toDisplay(file.createdAt)}.\n\n'
          'ALL current students, fees, attendance and other data will be replaced by the data '
          'in this backup. A safety copy of the current data is saved first. '
          'The app will restart when it is done.',
      confirmLabel: 'Restore',
    );
    if (ok) await cubit.restore(file);
  }

  void _showRestored(BuildContext context) {
    final cubit = context.read<BackupCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                  const SizedBox(height: 16),
                  Text('Restore complete', style: Theme.of(dialogContext).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Your data is back. The app must start again to show it.',
                    style: Theme.of(dialogContext).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Restart App',
                      icon: Icons.restart_alt_rounded,
                      onPressed: cubit.restartApp,
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

class _RestoringOverlay extends StatelessWidget {
  const _RestoringOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withValues(alpha: 0.85),
        child: const LoadingView(message: 'Restoring your data. Please do not close the app...'),
      ),
    );
  }
}
