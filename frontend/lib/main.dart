import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/app.dart';
import 'src/configs/injector/injector_conf.dart';
import 'src/core/cache/hive_local_storage.dart';
import 'src/core/cache/secure_local_storage.dart';

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
  await Hive.initFlutter();
  configureDepedencies();
  await _applyRememberMePolicy();
  runApp(App());
}
