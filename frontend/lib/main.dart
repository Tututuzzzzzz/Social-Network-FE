import 'dart:convert';
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
  
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Xin quyền và lấy Device Token
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token = await messaging.getToken();
  print("🎯 FCM Device Token của máy này là: $token");

  // 3. Đảm bảo getIt được khởi tạo TRƯỚC KHI xử lý notification 
  // (Để chắc chắn AppRoutesConf đã nằm trong bộ nhớ)
  configureDepedencies();
  await Hive.initFlutter();

  // 4. Khởi tạo Local Notification và xử lý Click Banner
  LocalNotificationHelper.initialize(
    onNotificationClick: (String? payload) {
      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload);
          final route = data['route'];

          if (route != null) {
            print("🚀 Đang tự động chuyển hướng đến màn hình: $route");
            
            // 👇 SỬ DỤNG GoRouter TỪ getIt ĐỂ CHUYỂN MÀN HÌNH
            getIt<AppRoutesConf>().router.push(route);
          }
        } catch (e) {
          print("Lỗi khi đọc payload chuyển màn hình: $e");
        }
      }
    },
  );

  // 5. "Trạm gác" hiển thị banner khi app đang mở
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🚨 BÍP BÍP! Đã bắt được thông báo khi đang mở app!');
    if (message.notification != null) {
      LocalNotificationHelper.display(message);
    }
  });

  // 6. Xử lý policy và chạy app
  await _applyRememberMePolicy();
  
  runApp(App());
}