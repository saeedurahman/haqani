import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/app_restarter.dart';
import '../../domain/backup_models.dart';
import '../../domain/backup_repository.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  BackupCubit(this._repository, this._restarter) : super(const BackupState());

  final BackupRepository _repository;
  final AppRestarter _restarter;

  Future<void> load() async {
    emit(state.copyWith(status: BackupStatus.loading));
    try {
      emit(state.copyWith(
        status: BackupStatus.success,
        settings: await _repository.getSettings(),
        localBackups: await _repository.listLocalBackups(),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: BackupStatus.failure,
        errorMessage: AppStrings.somethingWentWrong,
      ));
    }
  }

  Future<void> backupNow() async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: BackupBusy.backingUp));
    try {
      final result = await _repository.backupNow();
      final message = _backupMessage(result);
      emit(state.copyWith(
        busy: BackupBusy.none,
        settings: await _repository.getSettings(),
        localBackups: await _repository.listLocalBackups(),
        feedback: message.text,
        feedbackIsError: message.isError,
        feedbackId: state.feedbackId + 1,
      ));
    } on BackupException catch (e) {
      _notify(e.message, isError: true, busy: BackupBusy.none);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true, busy: BackupBusy.none);
    }
  }

  /// Pass null to go back to the app folder.
  Future<void> setFolder(String? path) async {
    try {
      await _repository.setBackupFolder(path);
      emit(state.copyWith(
        settings: await _repository.getSettings(),
        localBackups: await _repository.listLocalBackups(),
        feedback: path == null ? 'Backups are saved in the app folder.' : 'Backup folder changed.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on BackupException catch (e) {
      _notify(e.message, isError: true);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true);
    }
  }

  Future<void> connectDrive() async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: BackupBusy.connecting));
    try {
      final email = await _repository.connectDrive();
      emit(state.copyWith(
        busy: BackupBusy.none,
        settings: await _repository.getSettings(),
        feedback: 'Google Drive connected as $email.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } on BackupException catch (e) {
      _notify(e.message, isError: true, busy: BackupBusy.none);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true, busy: BackupBusy.none);
    }
  }

  Future<void> disconnectDrive() async {
    try {
      await _repository.disconnectDrive();
      emit(state.copyWith(
        settings: await _repository.getSettings(),
        driveBackups: const [],
        driveLoaded: false,
        feedback: 'Google Drive is disconnected. Your backups on Drive are not deleted.',
        feedbackIsError: false,
        feedbackId: state.feedbackId + 1,
      ));
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true);
    }
  }

  Future<void> loadDriveBackups() async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: BackupBusy.loadingDrive));
    try {
      final list = await _repository.listDriveBackups();
      emit(state.copyWith(busy: BackupBusy.none, driveBackups: list, driveLoaded: true));
    } on BackupException catch (e) {
      _notify(e.message, isError: true, busy: BackupBusy.none);
    } catch (_) {
      _notify(AppStrings.somethingWentWrong, isError: true, busy: BackupBusy.none);
    }
  }

  /// Replaces all data with the backup. On success [BackupState.restored] is
  /// true and the page asks the user to restart the app.
  Future<void> restore(BackupFile backup) async {
    if (state.isBusy) return;
    emit(state.copyWith(busy: BackupBusy.restoring));
    try {
      await _repository.restore(backup);
      emit(state.copyWith(busy: BackupBusy.none, restored: true));
    } on BackupException catch (e) {
      _notify(e.message, isError: true, busy: BackupBusy.none);
    } catch (_) {
      _notify(
        'The backup could not be restored. Your data was not changed.',
        isError: true,
        busy: BackupBusy.none,
      );
    }
  }

  Future<void> restartApp() => _restarter.restart();

  /// The backup is always saved here. If Drive did not work, say so in red.
  ({String text, bool isError}) _backupMessage(BackupResult result) {
    final saved = 'Backup saved on this computer (${result.file.name}).';
    switch (result.drive) {
      case DriveUploadStatus.notConnected:
        return (text: saved, isError: false);
      case DriveUploadStatus.uploaded:
        return (text: '$saved It was also uploaded to Google Drive.', isError: false);
      case DriveUploadStatus.offline:
      case DriveUploadStatus.failed:
        return (text: '$saved ${result.driveMessage ?? ''}'.trim(), isError: true);
    }
  }

  void _notify(String message, {required bool isError, BackupBusy? busy}) {
    emit(state.copyWith(
      busy: busy,
      feedback: message,
      feedbackIsError: isError,
      feedbackId: state.feedbackId + 1,
    ));
  }
}
