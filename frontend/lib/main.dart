import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; 

import 'src/app.dart';
import 'src/configs/injector/injector_conf.dart';
import 'src/core/cache/hive_local_storage.dart';
import 'src/core/cache/secure_local_storage.dart';
// Import helper hiển thị notification
import 'src/core/utils/local_notification_helper.dart'; 
import 'src/routes/app_route_conf.dart';


Future<void> _applyRememberMePolicy() async {
  final secureStorage = getIt<SecureLocalStorage>();
  final rememberMe = (await secureStorage.load(key: 'remember_me')).trim();

  if (rememberMe == 'true') {
    return;
  }

  await secureStorage.delete(key: 'access_token');
  await secureStorage.delete(key: 'refresh_token');
  await secureStorage.delete(key: 'user_id');

  final localStorage = getIt<HiveLocalStorage>();
  await localStorage.delete(key: 'user', boxName: 'cache');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phát hiện môi trường E2E để bỏ qua Firebase và FCM
  const isE2E = bool.fromEnvironment('IS_E2E', defaultValue: false);

  if (!isE2E) {
    // 1. Khởi tạo Firebase (chỉ trong môi trường thật, không phải E2E)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Xin quyền và lấy Device Token
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      String? token = await messaging.getToken();
      log('🎯 FCM Device Token của máy này là: $token', name: 'FCM');

      // 4. Khởi tạo Local Notification và xử lý Click Banner
      LocalNotificationHelper.initialize(
        onNotificationClick: (String? payload) {
          if (payload != null && payload.isNotEmpty) {
            try {
              final data = jsonDecode(payload);
              final route = data['route'];
              if (route != null) {
                log('🚀 Đang tự động chuyển hướng đến màn hình: $route', name: 'Notification');
                getIt<AppRoutesConf>().router.push(route);
              }
            } catch (e) {
              log('Lỗi khi đọc payload chuyển màn hình: $e', name: 'Notification');
            }
          }
        },
      );

      // 5. "Trạm gác" hiển thị banner khi app đang mở
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('🚨 BÍP BÍP! Đã bắt được thông báo khi đang mở app!', name: 'FCM');
        if (message.notification != null) {
          LocalNotificationHelper.display(message);
        }
      });
    } catch (e) {
      log('⚠️ Firebase init thất bại (có thể đang chạy trên emulator test): $e', name: 'Firebase');
    }
  } else {
    log('🧪 [E2E] Chế độ E2E: Bỏ qua khởi tạo Firebase và FCM.', name: 'E2E');
  }

  // 3. Đảm bảo getIt được khởi tạo TRƯỚC KHI xử lý notification
  configureDepedencies();
  await Hive.initFlutter();

  // 6. Xử lý policy và chạy app
  await _applyRememberMePolicy();

  runApp(App());
}