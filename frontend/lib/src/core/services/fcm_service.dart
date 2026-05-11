import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');

    final token = await _messaging.getToken();

    print('================ FCM TOKEN ================');
    print(token);
    print('===========================================');

    _messaging.onTokenRefresh.listen((newToken) {
      print('============== NEW FCM TOKEN ==============');
      print(newToken);
      print('===========================================');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận notification khi app đang mở');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User bấm vào notification');
      print('Data: ${message.data}');
    });

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('App được mở từ trạng thái tắt bằng notification');
      print('Data: ${initialMessage.data}');
    }
  }
}