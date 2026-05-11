import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'src/core/services/fcm_service.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/configs/injector/injector_conf.dart';
import 'src/core/cache/hive_local_storage.dart';
import 'src/core/cache/secure_local_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Background message ID: ${message.messageId}');
  print('Background message data: ${message.data}');
}

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();

  configureDepedencies();

  await _applyRememberMePolicy();

  await FcmService.init();

  runApp(App());
}