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
      id: 'p_1',
      kind: 'person',
      category: 'people',
      title: 'Linh Vo',
      subtitle: 'UI designer who loves cafe hopping',
      handle: 'linhvo',
      mutualFriends: 18,
      isOnline: true,
    ),
    HomeModel(
      id: 'p_2',
      kind: 'person',
      category: 'people',
      title: 'Khoa Tran',
      subtitle: 'Backend engineer, mobile enthusiast',
      handle: 'khoatran',
      mutualFriends: 11,
      isOnline: false,
    ),
    HomeModel(
      id: 'p_3',
      kind: 'person',
      category: 'people',
      title: 'Mina Le',
      subtitle: 'Photographer and traveler',
      handle: 'minale',
      mutualFriends: 26,
      isOnline: true,
    ),
    HomeModel(
      id: 'p_4',
      kind: 'person',
      category: 'people',
      title: 'Tuan Pham',
      subtitle: 'Community builder',
      handle: 'tuanpham',
      mutualFriends: 7,
      isOnline: false,
    ),
    HomeModel(
      id: 'p_5',
      kind: 'person',
      category: 'people',
      title: 'Hana Nguyen',
      subtitle: 'Motion designer',
      handle: 'hanang',
      mutualFriends: 9,
      isOnline: true,
    ),
    HomeModel(
      id: 'd_1',
      kind: 'discover',
      category: 'posts',
      title: 'Street Food',
      subtitle: '1.2k posts this week',
      iconKey: 'food',
    ),
    HomeModel(
      id: 'd_2',
      kind: 'discover',
      category: 'places',
      title: 'City Walks',
      subtitle: 'Nearby routes and photos',
      iconKey: 'route',
    ),
    HomeModel(
      id: 'd_3',
      kind: 'discover',
      category: 'posts',
      title: 'Live Music',
      subtitle: 'Tonight around you',
      iconKey: 'music',
    ),
    HomeModel(
      id: 'd_4',
      kind: 'discover',
      category: 'posts',
      title: 'Design Meetups',
      subtitle: '8 events this month',
      iconKey: 'design',
    ),
    HomeModel(
      id: 'd_5',
      kind: 'discover',
      category: 'photos',
      title: 'Photo Spots',
      subtitle: 'Top-rated corners',
      iconKey: 'photo',
    ),
    HomeModel(
      id: 'd_6',
      kind: 'discover',
      category: 'places',
      title: 'Coffee Labs',
      subtitle: 'Trending cafes',
      iconKey: 'coffee',
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
            id: 'person_$authorId',
            kind: 'person',
            category: 'people',
            title: authorLabel,
            subtitle: 'From your feed',
            handle: username,
            mutualFriends: (item['likesCount'] as num?)?.toInt() ?? 0,
            isOnline: false,
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
          id: 'discover_$postId',
          kind: 'discover',
          category: 'posts',
          title: content.isNotEmpty
              ? _trimWithEllipsis(content, 42)
              : (hasMedia ? 'Photo update' : 'New post'),
          subtitle: 'By $authorLabel',
          iconKey: hasMedia ? 'photo' : 'circle',
        ),
      );

      posts.add(
        HomeModel(
          id: 'post_$postId',
          kind: 'post',
          category: 'feed',
          title: authorLabel,
          subtitle: content.isNotEmpty ? content : 'Shared a new update',
          mediaUrl: mediaUrl,
          likesCount: likesCount,
          commentsCount: commentsCount,
          minutesAgo: _minutesAgo(createdAt),
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
