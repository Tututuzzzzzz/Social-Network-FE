import '../../domain/entities/notification_read_status_entity.dart';

class MarkAllNotificationsReadModel extends NotificationReadStatusEntity {
  const MarkAllNotificationsReadModel({
    super.message,
    super.notificationId,
    super.isRead,
    super.readAt,
    super.modifiedCount,
  });

  factory MarkAllNotificationsReadModel.fromJson(Map<String, dynamic> json) {
    return MarkAllNotificationsReadModel(
      message: json['message']?.toString() ?? '',
      modifiedCount: (json['modifiedCount'] as num?)?.toInt() ?? 0,
      isRead: true,
    );
  }
}
