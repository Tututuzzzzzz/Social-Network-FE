import 'package:equatable/equatable.dart';

import '../../../domain/entities/admin_session.dart';

enum AdminAuthStatus {
  checking,
  unauthenticated,
  submitting,
  authenticated,
  failure,
}

class AdminAuthState extends Equatable {
  final AdminAuthStatus status;
  final AdminSession? session;
  final String? message;

  const AdminAuthState({required this.status, this.session, this.message});

  const AdminAuthState.checking() : this(status: AdminAuthStatus.checking);

  const AdminAuthState.unauthenticated()
    : this(status: AdminAuthStatus.unauthenticated);

  bool get isAuthenticated => status == AdminAuthStatus.authenticated;

  AdminAuthState copyWith({
    AdminAuthStatus? status,
    AdminSession? session,
    String? message,
    bool clearMessage = false,
  }) {
    return AdminAuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
