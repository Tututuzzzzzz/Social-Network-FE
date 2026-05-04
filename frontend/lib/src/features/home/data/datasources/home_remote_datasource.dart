import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> fetchItems();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiHelper _apiHelper;

  const HomeRemoteDataSourceImpl(this._apiHelper);

  static const List<HomeModel> _mockItems = [
    HomeModel(
      id: '65f1a2b3c4d5e6f7a8b9c0d1',
      kind: 'person',
      category: 'people',
      title: 'Linh Vo',
      subtitle: 'UI designer who loves cafe hopping',
      handle: 'linhvo',
      mutualFriends: 18,
      isOnline: true,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d1',
    ),
    HomeModel(
      id: '65f1a2b3c4d5e6f7a8b9c0d2',
      kind: 'person',
      category: 'people',
      title: 'Khoa Tran',
      subtitle: 'Backend engineer, mobile enthusiast',
      handle: 'khoatran',
      mutualFriends: 11,
      isOnline: false,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d2',
    ),
    HomeModel(
      id: '65f1a2b3c4d5e6f7a8b9c0d3',
      kind: 'person',
      category: 'people',
      title: 'Mina Le',
      subtitle: 'Photographer and traveler',
      handle: 'minale',
      mutualFriends: 26,
      isOnline: true,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d3',
    ),
    HomeModel(
      id: '65f1a2b3c4d5e6f7a8b9c0d4',
      kind: 'person',
      category: 'people',
      title: 'Tuan Pham',
      subtitle: 'Community builder',
      handle: 'tuanpham',
      mutualFriends: 7,
      isOnline: false,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d4',
    ),
    HomeModel(
      id: '65f1a2b3c4d5e6f7a8b9c0d5',
      kind: 'person',
      category: 'people',
      title: 'Hana Nguyen',
      subtitle: 'Motion designer',
      handle: 'hanang',
      mutualFriends: 9,
      isOnline: true,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d5',
    ),
    HomeModel(
      id: 'd_1',
      kind: 'discover',
      category: 'posts',
      title: 'Street Food',
      subtitle: '1.2k posts this week',
      iconKey: 'food',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d1',
    ),
    HomeModel(
      id: 'd_2',
      kind: 'discover',
      category: 'places',
      title: 'City Walks',
      subtitle: 'Nearby routes and photos',
      iconKey: 'route',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d2',
    ),
    HomeModel(
      id: 'd_3',
      kind: 'discover',
      category: 'posts',
      title: 'Live Music',
      subtitle: 'Tonight around you',
      iconKey: 'music',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d3',
    ),
    HomeModel(
      id: 'd_4',
      kind: 'discover',
      category: 'posts',
      title: 'Design Meetups',
      subtitle: '8 events this month',
      iconKey: 'design',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d4',
    ),
    HomeModel(
      id: 'd_5',
      kind: 'discover',
      category: 'photos',
      title: 'Photo Spots',
      subtitle: 'Top-rated corners',
      iconKey: 'photo',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d5',
    ),
    HomeModel(
      id: 'd_6',
      kind: 'discover',
      category: 'places',
      title: 'Coffee Labs',
      subtitle: 'Trending cafes',
      iconKey: 'coffee',
      authorId: '65f1a2b3c4d5e6f7a8b9c0d1',
    ),
    HomeModel(
      id: 'post_1',
      kind: 'post',
      category: 'feed',
      title: 'Linh Vo',
      subtitle: 'Building Home feed with real API mapping.',
      mediaUrl: '',
      likesCount: 42,
      commentsCount: 6,
      minutesAgo: 8,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d1',
    ),
    HomeModel(
      id: 'post_2',
      kind: 'post',
      category: 'feed',
      title: 'Khoa Tran',
      subtitle: 'Direct Messages and Search are now backed by backend data.',
      mediaUrl: '',
      likesCount: 28,
      commentsCount: 3,
      minutesAgo: 19,
      authorId: '65f1a2b3c4d5e6f7a8b9c0d2',
    ),
  ];

  @override
  Future<List<HomeModel>> fetchItems() async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.postsFeed,
      );
      final items = _mapFeedToHomeItems(result);
      if (items.isNotEmpty) {
        return items;
      }
    } catch (_) {
      // Ignore and fall back to mocked data when API is unavailable.
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _mockItems;
  }

  List<HomeModel> _mapFeedToHomeItems(Map<String, dynamic> payload) {
    final dataRaw = payload['data'];
    if (dataRaw is! Map) {
      return const [];
    }

    final data = Map<String, dynamic>.from(dataRaw);
    final itemsRaw = data['items'];
    if (itemsRaw is! List) {
      return const [];
    }

    final people = <HomeModel>[];
    final discoveries = <HomeModel>[];
    final posts = <HomeModel>[];
    final seenAuthors = <String>{};

    for (final itemRaw in itemsRaw) {
      if (itemRaw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(itemRaw);
      final postId = _asText(item['_id']);
      if (postId.isEmpty) {
        continue;
      }

      final authorRaw = item['authorId'];
      Map<String, dynamic>? author;
      if (authorRaw is Map) {
        author = Map<String, dynamic>.from(authorRaw);
      }

      final authorId = _asText(author?['_id']);
      final displayName = _asText(author?['displayName']);
      final username = _asText(author?['username']);
      final authorLabel = displayName.isNotEmpty
          ? displayName
          : (username.isNotEmpty ? username : 'Unknown');

      if (authorId.isNotEmpty && seenAuthors.add(authorId)) {
        people.add(
          HomeModel(
            id: authorId,
            kind: 'person',
            category: 'people',
            title: authorLabel,
            subtitle: 'From your feed',
            handle: username,
            mutualFriends: (item['likesCount'] as num?)?.toInt() ?? 0,
            isOnline: false,
            authorId: authorId,
          ),
        );
      }

      final content = _asText(item['content']);
      final mediaRaw = item['media'];
      final hasMedia = mediaRaw is List && mediaRaw.isNotEmpty;

      final likesCount = (item['likesCount'] as num?)?.toInt() ?? 0;
      final commentsCount = (item['commentsCount'] as num?)?.toInt() ?? 0;
      final createdAt = _asText(item['createdAt']);

      String mediaUrl = '';
      if (mediaRaw is List && mediaRaw.isNotEmpty) {
        final firstMediaRaw = mediaRaw.first;
        if (firstMediaRaw is Map) {
          final firstMedia = Map<String, dynamic>.from(firstMediaRaw);
          mediaUrl = _asText(firstMedia['mediaUrl']);
        }
      }

      discoveries.add(
        HomeModel(
          id: postId,
          kind: 'discover',
          category: 'posts',
          title: content.isNotEmpty
              ? _trimWithEllipsis(content, 42)
              : (hasMedia ? 'Photo update' : 'New post'),
          subtitle: 'By $authorLabel',
          iconKey: hasMedia ? 'photo' : 'circle',
          authorId: authorId,
        ),
      );

      posts.add(
        HomeModel(
          id: postId,
          kind: 'post',
          category: 'feed',
          title: authorLabel,
          subtitle: content.isNotEmpty ? content : 'Shared a new update',
          mediaUrl: mediaUrl,
          likesCount: likesCount,
          commentsCount: commentsCount,
          minutesAgo: _minutesAgo(createdAt),
          authorId: authorId,
        ),
      );
    }

    return [...people, ...discoveries, ...posts];
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

  String _trimWithEllipsis(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 1)}...';
  }
}
