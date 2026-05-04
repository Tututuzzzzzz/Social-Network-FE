import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_post_detail.dart';

enum AdminPostDetailStatus { initial, loading, ready, failure }

class AdminPostDetailState extends Equatable {
  final AdminPostDetailStatus status;
  final AdminPostDetail? detail;
  final String? message;

  const AdminPostDetailState({required this.status, this.detail, this.message});

  const AdminPostDetailState.initial()
    : this(status: AdminPostDetailStatus.initial);

  AdminPostDetailState copyWith({
    AdminPostDetailStatus? status,
    AdminPostDetail? detail,
    String? message,
  }) {
    return AdminPostDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, detail, message];
}
