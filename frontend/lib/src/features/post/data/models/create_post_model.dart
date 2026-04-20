import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_media_entity.dart';
import 'post_media_model.dart';

class CreatePostModel {
  final String? content;
  final List<PostMediaEntity> media;

  const CreatePostModel({this.content, this.media = const []});

  factory CreatePostModel.fromJson(Map<String, dynamic> json) {
    return CreatePostModel(
      content: json['content'] as String?,
      media:
          (json['media'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => PostMediaModel.fromJson(Map<String, dynamic>.from(e)))
              .map((e) => e.toEntity())
              .toList() ??
          const [],
    );
  }

  factory CreatePostModel.fromEntity(PostEntity entity) {
    return CreatePostModel(content: entity.content, media: entity.media);
  }

  bool get hasContent => content != null && content!.trim().isNotEmpty;
  bool get hasMedia => media.isNotEmpty;
  bool get isValidPayload => hasContent || hasMedia;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (content != null) {
      map['content'] = content;
    }

    if (media.isNotEmpty) {
      map['media'] = media
          .map((e) => PostMediaModel.fromEntity(e).toJson())
          .toList();
    }

    return map;
  }
}
