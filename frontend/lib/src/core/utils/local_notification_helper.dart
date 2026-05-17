import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'logger.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize({required Function(String?) onNotificationClick}) {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.i("👇 Người dùng vừa bấm vào banner thông báo (khi app đang mở)!");
        
        // 👇 Khi có người bấm, ta đẩy cái payload ra ngoài cho main.dart xử lý
        onNotificationClick(response.payload); 
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'social_network_high_importance',
          'Thông báo hệ thống',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        // 👇 Đã khai báo rõ tên từng tham số
        id: id,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: notificationDetails,
        payload: message.data.toString(),
      );
    } on Exception catch (e) {
      logger.e("Lỗi khi hiển thị thông báo cục bộ: $e");
    }
  }
}