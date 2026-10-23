import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/snack.dart';
import '../../../shell/presentation/cubit/app_section.dart';
import '../../../shell/presentation/cubit/navigation_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/data_about_card.dart';
import '../widgets/logo_card.dart';
import '../widgets/school_info_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (a, b) => a.feedbackId != b.feedbackId && b.feedback != null,
      listener: (context, state) {
        if (state.feedbackIsError) {
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
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                      title: 'Settings',
                      subtitle: 'School information, logo and data',
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

  Widget _body(BuildContext context, SettingsState state) {
    switch (state.status) {
      case SettingsStatus.initial:
      case SettingsStatus.loading:
        return const LoadingView();
      case SettingsStatus.failure:
        return ErrorView(
          message: state.errorMessage,
          onRetry: () => context.read<SettingsCubit>().load(),
        );
      case SettingsStatus.success:
        final cubit = context.read<SettingsCubit>();
        final profile = state.profile!;
        return Scrollbar(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              SchoolInfoCard(
                profile: profile,
                isSaving: state.isSaving,
                onSave: (name, address, phone) =>
                    cubit.save(name: name, address: address, phone: phone),
              ),
              const SizedBox(height: 22),
              LogoCard(
                logoPath: profile.logoPath,
                isSaving: state.isSaving,
                onChoose: () => _chooseLogo(context),
                onRemove: () => _removeLogo(context),
              ),
              const SizedBox(height: 22),
              DataAboutCard(
                dataFolder: state.dataFolder,
                onOpenFolder: () => launchUrl(Uri.directory(state.dataFolder)),
                onOpenBackup: () => context.read<NavigationCubit>().select(AppSection.backup),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _chooseLogo(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      dialogTitle: 'Choose the school logo',
    );
    final path = picked?.path;
    if (path != null) await cubit.setLogo(path);
  }

  Future<void> _removeLogo(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final ok = await ConfirmDialog.show(
      context,
      title: 'Remove the logo?',
      message: 'The side menu will show the default picture again.',
      confirmLabel: 'Remove',
    );
    if (ok) await cubit.removeLogo();
  }
}
