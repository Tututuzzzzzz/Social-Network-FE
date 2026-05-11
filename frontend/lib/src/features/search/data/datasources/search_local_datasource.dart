import '../../../../core/cache/local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/search_entity.dart';

abstract class SearchLocalDataSource {
  Future<List<SearchHistoryEntry>> getSearchHistory();
  Future<void> saveSearchQuery(SearchHistoryEntry entry);
  Future<void> clearSearchHistory();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final LocalStorage _localStorage;

  const SearchLocalDataSourceImpl(this._localStorage);

  static const String _cacheBox = 'cache';
  static const String _historyKey = 'search_history';

  List<SearchHistoryEntry> _parseHistory(dynamic raw) {
    if (raw == null) {
      return const [];
    }

    if (raw is! List) {
      throw CacheException();
    }

    final entries = <SearchHistoryEntry>[];
    for (final item in raw) {
      if (item is Map) {
        entries.add(
          SearchHistoryEntry.fromMap(Map<String, dynamic>.from(item)),
        );
        continue;
      }

      if (item is String) {
        final label = item.trim();
        if (label.isNotEmpty) {
          entries.add(SearchHistoryEntry.query(label));
        }
      }
    }

    return entries.where((entry) => entry.label.trim().isNotEmpty).toList();
  }

  String _entryKey(SearchHistoryEntry entry) {
    final userId = entry.userId?.trim() ?? '';
    if (entry.isUser && userId.isNotEmpty) {
      return 'user:$userId';
    }

    return 'query:${entry.label.trim().toLowerCase()}';
  }

  @override
  Future<List<SearchHistoryEntry>> getSearchHistory() async {
    try {
      final raw = await _localStorage.load(
        key: _historyKey,
        boxName: _cacheBox,
      );

      return _parseHistory(raw);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveSearchQuery(SearchHistoryEntry entry) async {
    final normalized = entry.label.trim();
    if (normalized.isEmpty) {
      return;
    }

    try {
      final raw = await _localStorage.load(
        key: _historyKey,
        boxName: _cacheBox,
      );

      final history = _parseHistory(raw);
      final normalizedEntry = SearchHistoryEntry(
        label: normalized,
        userId: entry.userId,
        avatarUrl: entry.avatarUrl,
        isUser: entry.isUser,
      );

      final key = _entryKey(normalizedEntry);
      history.removeWhere((item) => _entryKey(item) == key);
      history.insert(0, normalizedEntry);

      if (history.length > 10) {
        history.removeRange(10, history.length);
      }

      await _localStorage.save(
        key: _historyKey,
        boxName: _cacheBox,
        value: history.map((entry) => entry.toMap()).toList(),
      );
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await _localStorage.delete(key: _historyKey, boxName: _cacheBox);
    } catch (_) {
      throw CacheException();
    }
  }
}
