import '../../domain/entities/notification_read_status_entity.dart';

class MarkNotificationReadModel extends NotificationReadStatusEntity {
  const MarkNotificationReadModel({
    super.message,
    super.notificationId,
    super.isRead,
    super.readAt,
    super.modifiedCount,
  });

  factory MarkNotificationReadModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is Map
        ? Map<String, dynamic>.from(dataRaw)
        : const <String, dynamic>{};

    return MarkNotificationReadModel(
      message: json['message']?.toString() ?? '',
      notificationId: (data['_id'] ?? data['id'])?.toString(),
      isRead: data['isRead'] == true,
      readAt: DateTime.tryParse(data['readAt']?.toString() ?? ''),
    );
  }
}
