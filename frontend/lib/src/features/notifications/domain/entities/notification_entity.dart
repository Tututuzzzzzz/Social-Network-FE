import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final String actorId;
  final String actorName;
  final String actorAvatarUrl;
  final String type;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.actorId,
    required this.actorName,
    required this.actorAvatarUrl,
    required this.type,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      type: type,
      title: title,
      body: body,
      entityType: entityType,
      entityId: entityId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    actorId,
    actorName,
    actorAvatarUrl,
    type,
    title,
    body,
    entityType,
    entityId,
    isRead,
    readAt,
    createdAt,
  ];
}
