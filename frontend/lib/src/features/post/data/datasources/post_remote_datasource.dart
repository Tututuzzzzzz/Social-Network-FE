import 'package:frontend/src/features/post/data/models/models.dart';

import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

sealed class PostRemoteDatasource {
  Future<List<PostModel>> fetchPosts();
  Future<void> createPost(CreatePostModel post);
  Future<void> updatePost(UpdatePostModel post);
  Future<void> deletePost(String postId);
}

class PostRemoteDatasourceImpl implements PostRemoteDatasource {
  final ApiHelper _apiHelper;
  const PostRemoteDatasourceImpl(this._apiHelper);

  @override
  Future<List<PostModel>> fetchPosts() => fetchPostsFromUrl("");

  Future<List<PostModel>> fetchPostsFromUrl(String url) async {
    try {
      final endpoint = url.trim().isEmpty ? ApiConstants.postsFeed : url;
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
  Future<void> createPost(CreatePostModel post) async {
    try {
      await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.posts,
        data: post.toJson(),
      );
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> updatePost(UpdatePostModel post) async {
    try {
      await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.postById(post.postId),
        data: post.toJson(),
      );
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _apiHelper.execute(
        method: Method.delete,
        url: ApiConstants.postById(postId),
      );
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

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

    final docs = result['docs'];
    if (docs is List) {
      return docs
          .whereType<Map>()
          .map((e) => _normalizePostMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    final items = result['items'];
    if (items is List) {
      return items
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
