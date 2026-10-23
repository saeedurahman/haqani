import 'package:equatable/equatable.dart';

import '../../domain/backup_models.dart';

enum BackupStatus { initial, loading, success, failure }

/// What the app is busy with, so the page can show progress.
enum BackupBusy { none, backingUp, connecting, loadingDrive, restoring }

class BackupState extends Equatable {
  const BackupState({
    this.status = BackupStatus.initial,
    this.settings,
    this.localBackups = const [],
    this.driveBackups = const [],
    this.driveLoaded = false,
    this.busy = BackupBusy.none,
    this.restored = false,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final BackupStatus status;
  final BackupSettings? settings;
  final List<BackupFile> localBackups;
  final List<BackupFile> driveBackups;

  /// True once the Drive list was loaded (it is only loaded on request).
  final bool driveLoaded;
  final BackupBusy busy;

  /// True after a successful restore. The app must restart now.
  final bool restored;
  final String? errorMessage;

  /// One-time message. [feedbackId] changes every time, so repeats show again.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  bool get isBusy => busy != BackupBusy.none;

  BackupState copyWith({
    BackupStatus? status,
    BackupSettings? settings,
    List<BackupFile>? localBackups,
    List<BackupFile>? driveBackups,
    bool? driveLoaded,
    BackupBusy? busy,
    bool? restored,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return BackupState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      localBackups: localBackups ?? this.localBackups,
      driveBackups: driveBackups ?? this.driveBackups,
      driveLoaded: driveLoaded ?? this.driveLoaded,
      busy: busy ?? this.busy,
      restored: restored ?? this.restored,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        settings,
        localBackups,
        driveBackups,
        driveLoaded,
        busy,
        restored,
        errorMessage,
        feedback,
        feedbackIsError,
        feedbackId,
      ];
}
