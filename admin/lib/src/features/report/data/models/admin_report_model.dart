import '../../domain/entities/admin_report.dart';

class AdminReportModel extends AdminReport {
  const AdminReportModel({
    required super.id,
    required super.targetId,
    required super.targetType,
    required super.reason,
    required super.reporterName,
    required super.status,
    required super.createdAt,
    super.targetAuthorName,
    super.targetAuthorUsername,
    super.targetAuthorAvatarUrl,
    super.targetContent,
    super.targetMediaUrls,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    final reporter = _mapOrNull(json['reporter']) ??
        _mapOrNull(json['reporterId']) ??
        _mapOrNull(json['user']);
    final targetValue = json['targetId'] ?? json['postId'];
    final post = _mapOrNull(json['post']) ??
        _mapOrNull(json['target']) ??
        _mapOrNull(targetValue);
    final author = post == null ? null : _authorMap(post);

    return AdminReportModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      targetId: _firstText([
        _idFromValue(targetValue),
        post?['_id'],
        post?['id'],
      ]),
      targetType: (json['targetType'] ?? 'post').toString(),
      reason: (json['reason'] ?? '').toString(),
      reporterName: (json['reporterName'] ??
              reporter?['displayName'] ??
              reporter?['username'] ??
              reporter?['_id'] ??
              reporter?['id'] ??
              json['reporterId'] ??
              'unknown')
          .toString(),
      status: (json['status'] ?? 'open').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      targetAuthorName: _nullableText([
        post?['authorDisplayName'],
        post?['displayName'],
        post?['authorName'],
        post?['name'],
        author?['displayName'],
        author?['fullName'],
        author?['name'],
        author?['username'],
      ]),
      targetAuthorUsername: _nullableText([
        post?['authorUsername'],
        post?['username'],
        post?['userName'],
        author?['username'],
        author?['userName'],
      ]),
      targetAuthorAvatarUrl: _nullableText([
        post?['authorAvatarUrl'],
        post?['avatarUrl'],
        post?['profilePicture'],
        post?['profileImage'],
        author?['avatarUrl'],
        author?['avatar'],
        author?['profilePicture'],
        author?['profileImage'],
      ]),
      targetContent: _nullableText([
        post?['content'],
        post?['caption'],
        post?['text'],
        post?['body'],
        post?['description'],
      ]),
      targetMediaUrls: _mediaUrls(post),
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static Map<String, dynamic>? _authorMap(Map<String, dynamic> json) {
    for (final key in [
      'authorId',
      'author',
      'userId',
      'user',
      'owner',
      'createdBy',
      'postedBy',
      'creator',
      'created_by',
    ]) {
      final value = json[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return null;
  }

  static String _idFromValue(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return _firstText([map['_id'], map['id']]);
    }
    return _firstText([value]);
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  static String? _nullableText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static List<String> _mediaUrls(Map<String, dynamic>? post) {
    if (post == null) {
      return const [];
    }

    for (final key in [
      'media',
      'medias',
      'attachments',
      'files',
      'images',
      'imageUrls',
      'mediaUrls',
      'urls',
    ]) {
      final value = post[key];
      if (value is List) {
        return value
            .map((item) {
              if (item is Map) {
                final map = Map<String, dynamic>.from(item);
                return _nullableText([
                  map['mediaUrl'],
                  map['url'],
                  map['publicUrl'],
                  map['objectKey'],
                ]);
              }
              return item.toString();
            })
            .whereType<String>()
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
    }

    final single = _nullableText([
      post['mediaUrl'],
      post['imageUrl'],
      post['url'],
      post['publicUrl'],
    ]);
    return single == null ? const [] : [single];
  }
}
