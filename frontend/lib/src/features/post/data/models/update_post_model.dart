import '../../domain/entities/post_media_entity.dart';

class UpdatePostModel {
  final String postId;
  final String? content;
  final List<PostMediaEntity>? media;
  final bool hasContentField;
  final bool hasMediaField;

  const UpdatePostModel({
    required this.postId,
    this.content,
    this.media,
    this.hasContentField = false,
    this.hasMediaField = false,
  });

  factory UpdatePostModel.fromJson(String postId, Map<String, dynamic> json) {
    final hasContentField = json.containsKey('content');
    final hasMediaField = json.containsKey('media');

    return UpdatePostModel(
      postId: postId,
      content: json['content'] as String?,
      media: (json['media'] as List<dynamic>?)
          ?.map(
            (e) => PostMediaEntity(
              bucket: e['bucket'] as String,
              objectKey: e['objectKey'] as String,
              mediaUrl: e['mediaUrl'] as String?,
              mimeType: e['mimeType'] as String,
              size: e['size'] as int,
            ),
          )
          .toList(),
      hasContentField: hasContentField,
      hasMediaField: hasMediaField,
    );
  }

  factory UpdatePostModel.withContent({
    required String postId,
    required String? content,
  }) {
    return UpdatePostModel(
      postId: postId,
      content: content,
      hasContentField: true,
    );
  }

  factory UpdatePostModel.withMedia({
    required String postId,
    required List<PostMediaEntity> media,
  }) {
    return UpdatePostModel(postId: postId, media: media, hasMediaField: true);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (hasContentField) {
      map['content'] = content;
    }

    if (hasMediaField) {
      map['media'] = (media ?? const <PostMediaEntity>[])
          .map(
            (e) => {
              'bucket': e.bucket,
              'objectKey': e.objectKey,
              'mediaUrl': e.mediaUrl,
              'mimeType': e.mimeType,
              'size': e.size,
            },
          )
          .toList();
    }

    return map;
  }
}
