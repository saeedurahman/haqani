import 'package:equatable/equatable.dart';

import '../../domain/staff_member.dart';

enum StaffFormStatus { initial, loading, ready, saving, saved, failure }

class StaffFormState extends Equatable {
  const StaffFormState({
    this.status = StaffFormStatus.initial,
    this.member,
    this.errorMessage,
    this.feedback,
    this.feedbackId = 0,
  });

  final StaffFormStatus status;

  /// The person being edited. Null when adding.
  final StaffMember? member;

  /// Load error, or the reason a save was refused.
  final String? errorMessage;

  /// One-time message after Deactivate / Activate.
  final String? feedback;
  final int feedbackId;

  bool get isEditing => member != null;

  StaffFormState copyWith({
    StaffFormStatus? status,
    StaffMember? member,
    String? errorMessage,
    String? feedback,
    int? feedbackId,
  }) {
    return StaffFormState(
      status: status ?? this.status,
      member: member ?? this.member,
      errorMessage: errorMessage,
      feedback: feedback,
      feedbackId: feedbackId ?? this.feedbackId,
    );
  }

  @override
  List<Object?> get props => [status, member, errorMessage, feedback, feedbackId];
}
