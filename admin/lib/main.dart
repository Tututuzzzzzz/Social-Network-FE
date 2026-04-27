import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/configs/injector/injector_conf.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const AdminApp());
}
