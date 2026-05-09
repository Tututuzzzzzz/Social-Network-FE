import 'package:dio/dio.dart';
import 'package:frontend/src/features/post/data/models/models.dart';

import '../../../../core/api/api_helper.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_media_entity.dart';
import '../../domain/entities/post_media_upload_file.dart';

sealed class PostRemoteDatasource {
  Future<List<PostModel>> fetchPosts();
  Future<PostModel> fetchPostById(String postId);
  Future<void> createPost(CreatePostModel post);
  Future<void> updatePost(UpdatePostModel post);
  Future<void> deletePost(String postId);
  Future<List<PostMediaEntity>> uploadMedia(List<PostMediaUploadFile> files);
  Future<PostModel> toggleLike(String postId);
  Future<PostCommentEntity> createComment(
    String postId,
    CreateCommentModel comment,
  );
  Future<PostCommentEntity> updateComment(
    String postId,
    String commentId,
    UpdateCommentModel comment,
  );
  Future<void> deleteComment(String postId, String commentId);
  Future<GetCommentsModel> getComments(String postId);
}

class PostRemoteDatasourceImpl implements PostRemoteDatasource {
  final ApiHelper _apiHelper;
  const PostRemoteDatasourceImpl(this._apiHelper);

  @override
  Future<List<PostModel>> fetchPosts() => fetchPostsFromUrl("");

  @override
  Future<PostModel> fetchPostById(String postId) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.postById(postId),
      );

      final map = _extractPostMap(result);
      if (map.isEmpty) {
        throw ServerException();
      }
      return PostModel.fromJson(_normalizePostMap(map));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

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

  @override
  Future<List<PostMediaEntity>> uploadMedia(
    List<PostMediaUploadFile> files,
  ) async {
    try {
      if (files.isEmpty) {
        return const [];
      }

      final multipartFiles = <MultipartFile>[];

      for (final file in files) {
        if (file.hasBytes) {
          multipartFiles.add(
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          );
          continue;
        }

        if (file.hasPath) {
          multipartFiles.add(
            await MultipartFile.fromFile(file.path!, filename: file.name),
          );
        }
      }

      if (multipartFiles.isEmpty) {
        return const [];
      }

      final formData = FormData.fromMap({
        'purpose': 'post',
        'files': multipartFiles,
      });

      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.mediaUpload,
        data: formData,
      );

      final uploadResponse = UploadMediaResponseModel.fromJson(result);
      return uploadResponse
          .toEntities()
          .where((item) => item.bucket.isNotEmpty && item.objectKey.isNotEmpty)
          .toList();
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<PostModel> toggleLike(String postId) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.postLike(postId),
      );

      final data = result['data'];
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : result is Map
          ? Map<String, dynamic>.from(result)
          : <String, dynamic>{};

      return PostModel.fromJson(_normalizePostMap(map));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<PostCommentEntity> createComment(
    String postId,
    CreateCommentModel comment,
  ) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.post,
        url: ApiConstants.postComments(postId),
        data: comment.toJson(),
      );
      return _commentFromResponse(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<PostCommentEntity> updateComment(
    String postId,
    String commentId,
    UpdateCommentModel comment,
  ) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.patch,
        url: ApiConstants.postCommentById(postId, commentId),
        data: comment.toJson(),
      );

      return _commentFromResponse(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _apiHelper.execute(
        method: Method.delete,
        url: ApiConstants.postCommentById(postId, commentId),
      );
      return;
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  @override
  Future<GetCommentsModel> getComments(String postId) async {
    try {
      final result = await _apiHelper.execute(
        method: Method.get,
        url: ApiConstants.postComments(postId),
      );

      return GetCommentsModel.fromJson(result);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      throw ServerException();
    }
  }

  PostCommentEntity _commentFromResponse(Map<String, dynamic> result) {
    final data = result['data'];
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : result is Map
        ? Map<String, dynamic>.from(result)
        : <String, dynamic>{};
    return _commentFromMap(map);
  }

  PostCommentEntity _commentFromMap(Map<String, dynamic> map) {
    final authorRaw = map['authorId'];
    final authorMap = authorRaw is Map
        ? Map<String, dynamic>.from(authorRaw)
        : null;
    final authorId = authorMap != null
        ? (authorMap['_id'] ?? authorMap['id'] ?? '').toString()
        : authorRaw?.toString() ?? '';

    return PostCommentEntity(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      parentCommentId: map['parentCommentId']?.toString(),
      authorId: authorId,
      authorUsername: _firstNonEmpty([
        map['authorUsername'],
        authorMap?['username'],
      ]),
      authorDisplayName: _firstNonEmpty([
        map['authorDisplayName'],
        authorMap?['displayName'],
        authorMap?['fullName'],
      ]),
      authorAvatarUrl: _firstNonEmpty([
        map['authorAvatarUrl'],
        map['avatarUrl'],
        authorMap?['avatarUrl'],
        authorMap?['avatar'],
      ]),
      content: map['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
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

  Map<String, dynamic> _extractPostMap(Map<String, dynamic> result) {
    final data = result['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final post = map['post'];
      if (post is Map) {
        return Map<String, dynamic>.from(post);
      }

      final item = map['item'];
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }

      if (map.containsKey('_id') || map.containsKey('id')) {
        return map;
      }
    }

    final post = result['post'];
    if (post is Map) {
      return Map<String, dynamic>.from(post);
    }

    final item = result['item'];
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }

    if (result.containsKey('_id') || result.containsKey('id')) {
      return result;
    }

    return const <String, dynamic>{};
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
              final commentAuthorMap = commentAuthor is Map
                  ? Map<String, dynamic>.from(commentAuthor)
                  : null;

              return {
                'id': (e['id'] ?? e['_id'] ?? '').toString(),
                'parentCommentId': e['parentCommentId']?.toString(),
                'authorId': commentAuthorId,
                'authorUsername': _firstNonEmpty([
                  e['authorUsername'],
                  commentAuthorMap?['username'],
                ]),
                'authorDisplayName': _firstNonEmpty([
                  e['authorDisplayName'],
                  commentAuthorMap?['displayName'],
                  commentAuthorMap?['fullName'],
                ]),
                'authorAvatarUrl': _firstNonEmpty([
                  e['authorAvatarUrl'],
                  e['avatarUrl'],
                  commentAuthorMap?['avatarUrl'],
                  commentAuthorMap?['avatar'],
                ]),
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

  String? _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return null;
  }
}
