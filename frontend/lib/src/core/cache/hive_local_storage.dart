import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_storage.dart';

class HiveLocalStorage implements LocalStorage {
  final Map<String, Future<Box<dynamic>>> _openingBoxes = {};
  static Future<void>? _initFuture;

  final String defaultBoxName;

  HiveLocalStorage({this.defaultBoxName = 'app_box'});

  Future<void> _ensureInitialized() {
    _initFuture ??= Hive.initFlutter();
    return _initFuture!;
  }

  Future<Box<dynamic>> _getBox(String? boxName) async {
    await _ensureInitialized();

    final name = boxName ?? defaultBoxName;

    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }

    if (_openingBoxes.containsKey(name)) {
      return _openingBoxes[name]!;
    }

    final future = Hive.openBox<dynamic>(name);
    _openingBoxes[name] = future;

    try {
      final box = await future;
      return box;
    } finally {
      _openingBoxes.remove(name);
    }
  }

  @override
  Future<dynamic> load({required String key, String? boxName}) async {
    final box = await _getBox(boxName);
    return box.get(key);
  }

  @override
  Future<void> save({
    required String key,
    required dynamic value,
    String? boxName,
  }) async {
    final box = await _getBox(boxName);
    await box.put(key, value);
  }

  @override
  Future<void> delete({required String key, String? boxName}) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  Future<void> closeAll() async {
    await Hive.close();
  }
}
