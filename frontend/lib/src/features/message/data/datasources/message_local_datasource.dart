import '../../../../core/cache/local_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/message_model.dart';

abstract class MessageLocalDataSource {
  Future<MessageHistoryPageModel?> loadConversationHistory({
    required String conversationId,
  });

  Future<void> saveConversationHistory({
    required String conversationId,
    required MessageHistoryPageModel page,
  });
}

class MessageLocalDataSourceImpl implements MessageLocalDataSource {
  final LocalStorage _localStorage;

  const MessageLocalDataSourceImpl(this._localStorage);

  static const _cacheBox = 'cache';

  String _historyKey(String conversationId) =>
      'message_history_${conversationId.trim()}';

  @override
  Future<MessageHistoryPageModel?> loadConversationHistory({
    required String conversationId,
  }) async {
    final key = _historyKey(conversationId);

    try {
      final raw = await _localStorage.load(key: key, boxName: _cacheBox);
      if (raw == null) {
        return null;
      }

      if (raw is! Map) {
        throw CacheException();
      }

      return MessageHistoryPageModel.fromCacheJson(
        Map<String, dynamic>.from(raw),
      );
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveConversationHistory({
    required String conversationId,
    required MessageHistoryPageModel page,
  }) async {
    final key = _historyKey(conversationId);

    try {
      await _localStorage.save(
        key: key,
        boxName: _cacheBox,
        value: page.toCacheJson(),
      );
    } catch (_) {
      throw CacheException();
    }
  }
}
