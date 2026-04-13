import '../../domain/entities/post_media_entity.dart';

class PostMediaModel extends PostMediaEntity {
  PostMediaModel({
    required super.bucket,
    required super.objectKey,
    super.mediaUrl,
    required super.mimeType,
    required super.size,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      bucket: (json['bucket'] ?? '').toString(),
      objectKey: (json['objectKey'] ?? '').toString(),
      mediaUrl: (json['mediaUrl'] ?? json['url'] ?? json['publicUrl'])
          ?.toString(),
      mimeType: (json['mimeType'] ?? 'image/jpeg').toString(),
      size: (json['size'] as num?)?.toInt() ?? 0,
    );
  }

  factory PostMediaModel.fromEntity(PostMediaEntity entity) {
    return PostMediaModel(
      bucket: entity.bucket,
      objectKey: entity.objectKey,
      mediaUrl: entity.mediaUrl,
      mimeType: entity.mimeType,
      size: entity.size,
    );
  }

  PostMediaEntity toEntity() {
    return PostMediaEntity(
      bucket: bucket,
      objectKey: objectKey,
      mediaUrl: mediaUrl,
      mimeType: mimeType,
      size: size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'objectKey': objectKey,
      'mediaUrl': mediaUrl,
      'mimeType': mimeType,
      'size': size,
    };
  }
}
