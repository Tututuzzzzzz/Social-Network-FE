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
  Future<void> createPost(CreatePostModel post);
  Future<void> updatePost(UpdatePostModel post);
  Future<void> deletePost(String postId);
  Future<List<PostMediaEntity>> uploadMedia(List<PostMediaUploadFile> files);
  Future<PostModel> toggleLike(String postId);
  Future<PostCommentEntity> createComment(
    String postId,
    CreateCommentModel comment,
  );
  Future<GetCommentsModel> getComments(String postId);
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
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            ),
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

      final data = result['data'];
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : result is Map
          ? Map<String, dynamic>.from(result)
          : <String, dynamic>{};

      final authorRaw = map['authorId'];
      final authorId = authorRaw is Map
          ? (authorRaw['_id'] ?? authorRaw['id'] ?? '').toString()
          : authorRaw?.toString() ?? '';

      return PostCommentEntity(
        id: (map['_id'] ?? map['id'] ?? '').toString(),
        parentCommentId: map['parentCommentId']?.toString(),
        authorId: authorId,
        content: map['content']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      );
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
              final commentAuthorMap = commentAuthor is Map
                  ? Map<String, dynamic>.from(commentAuthor)
                  : null;

              return {
                'id': (e['id'] ?? e['_id'] ?? '').toString(),
                'parentCommentId': e['parentCommentId']?.toString(),
                'authorId': commentAuthorId,
                'authorUsername': commentAuthorMap?['username']?.toString(),
                'authorDisplayName': (commentAuthorMap?['displayName'] ??
                        commentAuthorMap?['fullName'])
                    ?.toString(),
                'authorAvatarUrl': commentAuthorMap?['avatarUrl']?.toString(),
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
