import 'dart:ui';
import '../../../../core/cache/hive_local_storage.dart';

abstract class LanguageRepository {
  Future<Locale?> getSavedLocale();
  Future<void> saveLocale(Locale locale);
}

class LanguageRepositoryImpl implements LanguageRepository {
  final HiveLocalStorage _localStorage;
  static const String _key = 'app_language';
  static const String _box = 'settings';

  LanguageRepositoryImpl(this._localStorage);

  @override
  Future<Locale?> getSavedLocale() async {
    final languageCode = await _localStorage.load(
      key: _key,
      boxName: _box,
    );
    if (languageCode != null && languageCode.isNotEmpty) {
      return Locale(languageCode);
    }
    return null;
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await _localStorage.save(
      key: _key,
      value: locale.languageCode,
      boxName: _box,
    );
  }
}
