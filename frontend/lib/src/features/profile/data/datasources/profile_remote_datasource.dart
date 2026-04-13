import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_helper.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> fetchItems();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiHelper _apiHelper;

  const ProfileRemoteDataSourceImpl(this._apiHelper);

  static const ProfileModel _fallback = ProfileModel(
    id: 'me',
    displayName: 'Mochi User',
    username: 'mochi_user',
    bio: 'Build social moments with your friends.',
    postsCount: 0,
    friendsCount: 0,
    posts: [],
  );

  @override
  Future<List<ProfileModel>> fetchItems() async {
    try {
      final meResult = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.profile,
      );

      final user = _extractUser(meResult);
      if (user == null) {
        return const [_fallback];
      }

      final userId = _asText(user['_id']);
      final displayName = _asText(user['displayName']);
      final username = _asText(user['username']);

      int postsCount = 0;
      int friendsCount = 0;
      var posts = const <ProfilePostPreview>[];

      if (userId.isNotEmpty) {
        try {
          final profileStatsResult = await _apiHelper.execute(
            method: Method.get,
            url: ApiConstants.userProfile(userId),
          );

          final dataRaw = profileStatsResult['data'];
          if (dataRaw is Map) {
            final data = Map<String, dynamic>.from(dataRaw);
            final statsRaw = data['stats'];
            if (statsRaw is Map) {
              final stats = Map<String, dynamic>.from(statsRaw);
              postsCount = (stats['postsCount'] as num?)?.toInt() ?? postsCount;
              friendsCount =
                  (stats['friendsCount'] as num?)?.toInt() ?? friendsCount;
            }
          }
        } catch (_) {
          // Ignore stats endpoint errors and continue with me/posts data.
        }

        try {
          final postsResult = await _apiHelper.execute(
            method: Method.get,
            url: ApiConstants.userPosts(userId, page: 1, limit: 9),
          );

          final mappedPosts = _mapPosts(postsResult);
          if (mappedPosts.isNotEmpty) {
            posts = mappedPosts;
          }

          final dataRaw = postsResult['data'];
          if (dataRaw is Map) {
            final data = Map<String, dynamic>.from(dataRaw);
            postsCount = (data['total'] as num?)?.toInt() ?? postsCount;
          }
        } catch (_) {
          // Ignore posts endpoint errors and keep profile header data.
        }
      }

      final model = ProfileModel(
        id: userId.isNotEmpty ? userId : 'me',
        displayName: displayName.isNotEmpty ? displayName : username,
        username: username,
        bio: _asText(user['bio']),
        avatarUrl: _asText(user['avatarUrl']),
        postsCount: postsCount,
        friendsCount: friendsCount,
        posts: posts,
      );

      return [model];
    } catch (_) {
      return const [_fallback];
    }
  }

  Map<String, dynamic>? _extractUser(Map<String, dynamic> payload) {
    final userRaw = payload['user'];
    if (userRaw is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(userRaw);
  }

  List<ProfilePostPreview> _mapPosts(Map<String, dynamic> payload) {
    final dataRaw = payload['data'];
    if (dataRaw is! Map) {
      return const [];
    }

    final data = Map<String, dynamic>.from(dataRaw);
    final itemsRaw = data['items'];
    if (itemsRaw is! List) {
      return const [];
    }

    final posts = <ProfilePostPreview>[];
    for (final itemRaw in itemsRaw) {
      if (itemRaw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(itemRaw);
      final id = _asText(item['_id']);
      if (id.isEmpty) {
        continue;
      }

      var mediaUrl = '';
      final mediaRaw = item['media'];
      if (mediaRaw is List && mediaRaw.isNotEmpty) {
        final firstRaw = mediaRaw.first;
        if (firstRaw is Map) {
          final first = Map<String, dynamic>.from(firstRaw);
          mediaUrl = _asText(first['mediaUrl']);
        }
      }

      posts.add(
        ProfilePostPreview(
          id: id,
          mediaUrl: mediaUrl,
          caption: _asText(item['content']),
          likesCount: (item['likesCount'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return posts;
  }

  String _asText(Object? value) {
    return value?.toString().trim() ?? '';
  }
}
