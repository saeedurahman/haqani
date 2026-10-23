import 'package:equatable/equatable.dart';

import '../../domain/school_profile.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.profile,
    this.dataFolder = '',
    this.isSaving = false,
    this.errorMessage,
    this.feedback,
    this.feedbackIsError = false,
    this.feedbackId = 0,
  });

  final SettingsStatus status;
  final SchoolProfile? profile;
  final String dataFolder;
  final bool isSaving;
  final String? errorMessage;

  /// One-time message after Save. [feedbackId] changes every time.
  final String? feedback;
  final bool feedbackIsError;
  final int feedbackId;

  SettingsState copyWith({
    SettingsStatus? status,
    SchoolProfile? profile,
    String? dataFolder,
    bool? isSaving,
    String? errorMessage,
    String? feedback,
    bool? feedbackIsError,
    int? feedbackId,
  }) {
    return SettingsState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      dataFolder: dataFolder ?? this.dataFolder,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props =>
      [status, profile, dataFolder, isSaving, errorMessage, feedback, feedbackIsError, feedbackId];
}
