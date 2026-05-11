import 'package:flutter/material.dart';

import '../cache/hive_local_storage.dart';

abstract class ThemeRepository {
  Future<ThemeMode> getSavedThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._localStorage);

  final HiveLocalStorage _localStorage;
  static const String _key = 'app_theme_mode';
  static const String _box = 'settings';

  @override
  Future<ThemeMode> getSavedThemeMode() async {
    final value = await _localStorage.load(key: _key, boxName: _box);
    if (value == 'dark') {
      return ThemeMode.dark;
    }
    if (value == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode.light;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await _localStorage.save(key: _key, value: value, boxName: _box);
  }
}
