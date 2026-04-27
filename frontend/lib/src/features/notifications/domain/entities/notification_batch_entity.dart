import 'package:equatable/equatable.dart';

import 'notification_entity.dart';

class NotificationBatchEntity extends Equatable {
  final List<NotificationEntity> items;
  final int page;
  final int limit;
  final int total;
  final int unreadCount;
  final bool hasMore;

  const NotificationBatchEntity({
    this.items = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.unreadCount = 0,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [items, page, limit, total, unreadCount, hasMore];
}
