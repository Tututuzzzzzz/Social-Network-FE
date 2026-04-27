import '../../domain/entities/notification_batch_entity.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.actorId,
    required super.actorName,
    required super.actorAvatarUrl,
    required super.type,
    required super.title,
    required super.body,
    super.entityType,
    super.entityId,
    required super.isRead,
    super.readAt,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actorRaw = json['actorId'];
    final actor = actorRaw is Map
        ? Map<String, dynamic>.from(actorRaw)
        : const <String, dynamic>{};

    final actorUsername = actor['username']?.toString().trim() ?? '';
    final actorDisplayName = actor['displayName']?.toString().trim() ?? '';

    final actorName = actorDisplayName.isNotEmpty
        ? actorDisplayName
        : actorUsername;

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      recipientId: json['recipientId']?.toString() ?? '',
      actorId: actorRaw is Map
          ? (actor['_id'] ?? actor['id'] ?? '').toString()
          : actorRaw?.toString() ?? '',
      actorName: actorName,
      actorAvatarUrl: actor['avatarUrl']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      entityType: json['entityType']?.toString(),
      entityId: json['entityId']?.toString(),
      isRead: json['isRead'] == true,
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class GetNotificationsModel extends NotificationBatchEntity {
  const GetNotificationsModel({
    super.items,
    super.page,
    super.limit,
    super.total,
    super.unreadCount,
    super.hasMore,
  });

  factory GetNotificationsModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map
        ? Map<String, dynamic>.from(dataRaw)
        : const <String, dynamic>{};

    final itemsRaw = data['items'];
    final items = <NotificationEntity>[];

    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is! Map) {
          continue;
        }
        items.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return GetNotificationsModel(
      items: items,
      page: (data['page'] as num?)?.toInt() ?? 1,
      limit: (data['limit'] as num?)?.toInt() ?? 20,
      total: (data['total'] as num?)?.toInt() ?? 0,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      hasMore: data['hasMore'] == true,
    );
  }
}
