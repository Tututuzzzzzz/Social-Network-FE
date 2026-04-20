import 'package:frontend/src/features/profile/data/models/models.dart';
import 'package:frontend/src/features/post/data/models/models.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

sealed class ProfileRemoteDataSource {
  Future<ProfileModel> fetchProfile(String userId);
  Future<void> updateProfile({String? displayName, String? bio, String? phone});
  Future<void> updateAvatar({
    required List<int> avatarBytes,
    required String fileName,
  });
  Future<List<PostModel>> fetchUserPosts(
    String userId, {
    int page = 1,
    int limit = 20,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiHelper _apiHelper;
  const ProfileRemoteDataSourceImpl(this._apiHelper);

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    try {
      final normalizedUserId = userId.trim();
      if (normalizedUserId.isEmpty) {
        throw ServerException();
      }

      final endpoint = ApiConstants.userProfile(normalizedUserId);
      final result = await _apiHelper.execute(
        method: Method.get,
        url: endpoint,
      );
      return ProfileModel.fromJson(_normalizeProfileJson(result));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<List<PostModel>> fetchUserPosts(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final normalizedUserId = userId.trim();
      if (normalizedUserId.isEmpty) {
        throw ServerException();
      }

      final endpoint = ApiConstants.userPosts(
        normalizedUserId,
        page: page,
        limit: limit,
      );

      final result = await _apiHelper.execute(
        method: Method.get,
        url: endpoint,
      );

      final postMaps = _extractPostMaps(result);
      return postMaps.map(PostModel.fromJson).toList();
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? phone,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (displayName != null) {
        payload['displayName'] = displayName;
      }
      if (bio != null) {
        payload['bio'] = bio;
      }
      if (phone != null) {
        payload['phone'] = phone;
      }

      await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.profile,
        data: payload,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> updateAvatar({
    required List<int> avatarBytes,
    required String fileName,
  }) async {
    try {
      if (avatarBytes.isEmpty || fileName.trim().isEmpty) {
        throw ServerException();
      }

      final formData = FormData.fromMap({
        'avatar': [MultipartFile.fromBytes(avatarBytes, filename: fileName)],
      });

      await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.profileAvatar,
        data: formData,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  Map<String, dynamic> _normalizeProfileJson(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return {'id': '', 'username': ''};
    }

    final data = payload['data'];
    final dataMap = data is Map<String, dynamic> ? data : null;
    final userRaw = dataMap?['user'] ?? payload['user'] ?? dataMap;
    final user = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : <String, dynamic>{};
    final statsRaw = dataMap?['stats'] ?? payload['stats'];
    final stats = statsRaw is Map
        ? Map<String, dynamic>.from(statsRaw)
        : <String, dynamic>{};

    final postsRaw = user['posts'] ?? payload['posts'] ?? dataMap?['posts'];
    final posts = postsRaw is List ? postsRaw : const [];

    return {
      'id': _asText(user['_id']).isNotEmpty
          ? _asText(user['_id'])
          : _asText(user['id']),
      'username': _asText(user['username']),
      'displayName': _asText(user['displayName']),
      'bio': _asText(user['bio']),
      'avatarUrl': _asText(user['avatarUrl']).isNotEmpty
          ? _asText(user['avatarUrl'])
          : (_asText(user['avatar']).isNotEmpty
                ? _asText(user['avatar'])
                : _asText(user['profileImage'])),
      'postsCount':
          _toInt(stats['postsCount']) ??
          _toInt(user['postsCount']) ??
          posts.length,
      'friendsCount':
          _toInt(stats['friendsCount']) ??
          _toInt(user['friendsCount']) ??
          _toInt(user['followersCount']) ??
          0,
      'posts': posts,
    };
  }

  int? _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value');
  }

  String _asText(dynamic value) => value?.toString() ?? '';

  List<Map<String, dynamic>> _extractPostMaps(Map<String, dynamic> result) {
    final data = result['data'];

    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => _normalizePostMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => _normalizePostMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return const [];
  }

  Map<String, dynamic> _normalizePostMap(Map<String, dynamic> raw) {
    final author = raw['authorId'];
    final authorMap = author is Map ? Map<String, dynamic>.from(author) : null;

    final media =
        (raw['media'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(
              (e) => {
                'bucket': (e['bucket'] ?? '').toString(),
                'objectKey': (e['objectKey'] ?? '').toString(),
                'mediaUrl': e['mediaUrl']?.toString(),
                'mimeType': (e['mimeType'] ?? '').toString(),
                'size': (e['size'] as num?)?.toInt() ?? 0,
              },
            )
            .toList() ??
        const [];

    final likes =
        (raw['likes'] as List?)
            ?.map((e) {
              if (e is Map) {
                final map = Map<String, dynamic>.from(e);
                return (map['_id'] ?? map['id'] ?? '').toString();
              }
              return e.toString();
            })
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [];

    final comments =
        (raw['comments'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map((e) {
              final commentAuthor = e['authorId'];
              final commentAuthorId = commentAuthor is Map
                  ? (Map<String, dynamic>.from(commentAuthor)['_id'] ??
                            Map<String, dynamic>.from(commentAuthor)['id'] ??
                            '')
                        .toString()
                  : (commentAuthor ?? '').toString();

              return {
                'id': (e['id'] ?? e['_id'] ?? '').toString(),
                'parentCommentId': e['parentCommentId']?.toString(),
                'authorId': commentAuthorId,
                'content': (e['content'] ?? '').toString(),
                'createdAt': _toIsoString(e['createdAt']),
                'updatedAt': _toIsoString(e['updatedAt']),
              };
            })
            .toList() ??
        const [];

    return {
      'id': (raw['id'] ?? raw['_id'] ?? '').toString(),
      'authorId': authorMap == null
          ? (author ?? '').toString()
          : (authorMap['_id'] ?? authorMap['id'] ?? '').toString(),
      'authorUsername': authorMap == null
          ? null
          : authorMap['username']?.toString(),
      'authorDisplayName': authorMap == null
          ? null
          : (authorMap['displayName'] ?? authorMap['fullName'])?.toString(),
      'authorAvatarUrl': authorMap == null
          ? null
          : (authorMap['avatarUrl'] ?? authorMap['avatar'])?.toString(),
      'content': raw['content']?.toString(),
      'media': media,
      'likes': likes,
      'comments': comments,
      'commentsCount':
          (raw['commentsCount'] as num?)?.toInt() ?? comments.length,
      'createdAt': _toIsoString(raw['createdAt']),
      'updatedAt': _toIsoString(raw['updatedAt']),
    };
  }

  String _toIsoString(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return DateTime.now().toIso8601String();
  }
}
