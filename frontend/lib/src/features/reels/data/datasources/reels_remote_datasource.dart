import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../models/reels_model.dart';

abstract class ReelsRemoteDataSource {
  Future<List<ReelsModel>> fetchItems();
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final ApiHelper _apiHelper;

  const ReelsRemoteDataSourceImpl(this._apiHelper);

  static const List<ReelsModel> _mockItems = [
    ReelsModel(
      id: 'reel_1',
      authorName: 'Mochi Team',
      caption: 'Welcome to the updated reels feed.',
      likesCount: 128,
      commentsCount: 14,
      minutesAgo: 6,
    ),
    ReelsModel(
      id: 'reel_2',
      authorName: 'Linh Vo',
      caption: 'Short vertical clips now come from API feed mapping.',
      likesCount: 96,
      commentsCount: 8,
      minutesAgo: 21,
    ),
  ];

  @override
  Future<List<ReelsModel>> fetchItems() async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: '${ApiConstants.postsFeed}?limit=30&page=1',
      );
      final items = _mapFeedToReelsItems(result);
      if (items.isNotEmpty) {
        return items;
      }
    } catch (_) {
      // Ignore and use fallback items.
    }

    return _mockItems;
  }

  List<ReelsModel> _mapFeedToReelsItems(Map<String, dynamic> payload) {
    final dataRaw = payload['data'];
    if (dataRaw is! Map) {
      return const [];
    }

    final data = Map<String, dynamic>.from(dataRaw);
    final itemsRaw = data['items'];
    if (itemsRaw is! List) {
      return const [];
    }

    final items = <ReelsModel>[];
    for (final itemRaw in itemsRaw) {
      if (itemRaw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(itemRaw);
      final postId = _asText(item['_id']);
      if (postId.isEmpty) {
        continue;
      }

      final mediaRaw = item['media'];
      String mediaUrl = '';
      if (mediaRaw is List && mediaRaw.isNotEmpty) {
        final firstMediaRaw = mediaRaw.first;
        if (firstMediaRaw is Map) {
          final firstMedia = Map<String, dynamic>.from(firstMediaRaw);
          mediaUrl = _asText(firstMedia['mediaUrl']);
        }
      }

      final authorRaw = item['authorId'];
      String authorName = 'Unknown';
      if (authorRaw is Map) {
        final author = Map<String, dynamic>.from(authorRaw);
        authorName = _asText(author['displayName']);
        if (authorName.isEmpty) {
          authorName = _asText(author['username']);
        }
      }
      if (authorName.isEmpty) {
        authorName = 'Unknown';
      }

      final caption = _asText(item['content']);
      final likesCount = (item['likesCount'] as num?)?.toInt() ?? 0;
      final commentsCount = (item['commentsCount'] as num?)?.toInt() ?? 0;
      final createdAt = _asText(item['createdAt']);

      items.add(
        ReelsModel(
          id: postId,
          authorName: authorName,
          caption: caption,
          mediaUrl: mediaUrl,
          likesCount: likesCount,
          commentsCount: commentsCount,
          minutesAgo: _minutesAgo(createdAt),
        ),
      );
    }

    return items;
  }

  int _minutesAgo(String isoValue) {
    if (isoValue.isEmpty) {
      return 0;
    }

    final parsed = DateTime.tryParse(isoValue);
    if (parsed == null) {
      return 0;
    }

    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.isNegative) {
      return 0;
    }

    return diff.inMinutes;
  }

  String _asText(Object? value) {
    return value?.toString().trim() ?? '';
  }
}
