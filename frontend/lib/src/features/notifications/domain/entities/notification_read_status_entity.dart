import 'package:equatable/equatable.dart';

class NotificationReadStatusEntity extends Equatable {
  final String message;
  final String? notificationId;
  final bool? isRead;
  final DateTime? readAt;
  final int? modifiedCount;

  const NotificationReadStatusEntity({
    this.message = '',
    this.notificationId,
    this.isRead,
    this.readAt,
    this.modifiedCount,
  });

  @override
  List<Object?> get props => [
    message,
    notificationId,
    isRead,
    readAt,
    modifiedCount,
  ];
}
