import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  final bool refresh;
  final bool unreadOnly;

  const NotificationLoadRequested({
    this.refresh = false,
    this.unreadOnly = false,
  });

  @override
  List<Object?> get props => [refresh, unreadOnly];
}

class NotificationLoadMoreRequested extends NotificationEvent {}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {}

class NotificationAcceptFriendRequestRequested extends NotificationEvent {
  final String requestId;
  final String notificationId;

  const NotificationAcceptFriendRequestRequested(
    this.requestId,
    this.notificationId,
  );

  @override
  List<Object?> get props => [requestId, notificationId];
}

class NotificationRejectFriendRequestRequested extends NotificationEvent {
  final String requestId;
  final String notificationId;

  const NotificationRejectFriendRequestRequested(
    this.requestId,
    this.notificationId,
  );

  @override
  List<Object?> get props => [requestId, notificationId];
}
