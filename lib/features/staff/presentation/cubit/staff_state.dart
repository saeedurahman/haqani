import 'package:equatable/equatable.dart';

import '../../domain/staff_member.dart';

enum StaffStatus { initial, loading, success, failure }

class StaffState extends Equatable {
  const StaffState({
    this.status = StaffStatus.initial,
    this.staff = const [],
    this.query = '',
    this.includeInactive = false,
    this.errorMessage,
  });

  final StaffStatus status;
  final List<StaffMember> staff;
  final String query;
  final bool includeInactive;
  final String? errorMessage;

  bool get hasFilter => query.trim().isNotEmpty;

  StaffState copyWith({
    StaffStatus? status,
    List<StaffMember>? staff,
    String? query,
    bool? includeInactive,
    String? errorMessage,
  }) {
    return StaffState(
      status: status ?? this.status,
      staff: staff ?? this.staff,
      query: query ?? this.query,
      includeInactive: includeInactive ?? this.includeInactive,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, staff, query, includeInactive, errorMessage];
}
