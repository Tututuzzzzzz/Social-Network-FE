import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_user_detail.dart';

enum AdminUserDetailStatus { initial, loading, ready, failure }

class AdminUserDetailState extends Equatable {
  final AdminUserDetailStatus status;
  final AdminUserDetail? detail;
  final String? message;

  const AdminUserDetailState({required this.status, this.detail, this.message});

  const AdminUserDetailState.initial()
    : this(status: AdminUserDetailStatus.initial);

  AdminUserDetailState copyWith({
    AdminUserDetailStatus? status,
    AdminUserDetail? detail,
    String? message,
  }) {
    return AdminUserDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, detail, message];
}
