import '../../domain/entities/admin_post_media.dart';

class AdminPostMediaModel extends AdminPostMedia {
  const AdminPostMediaModel({
    required super.bucket,
    required super.objectKey,
    required super.mimeType,
    required super.size,
    super.mediaUrl,
  });

  factory AdminPostMediaModel.fromJson(Map<String, dynamic> json) {
    final mediaUrl =
        (json['mediaUrl'] ??
                json['url'] ??
                json['publicUrl'] ??
                json['signedUrl'] ??
                json['secureUrl'] ??
                json['src'])
            ?.toString();
    final objectKey = (json['objectKey'] ?? json['key'] ?? json['path'] ?? '')
        .toString();
    final resolvedUrl = mediaUrl == null || mediaUrl.trim().isEmpty
        ? _urlFromObjectKey(objectKey)
        : mediaUrl;

    return AdminPostMediaModel(
      bucket: (json['bucket'] ?? '').toString(),
      objectKey: objectKey,
      mimeType:
          (json['mimeType'] ??
                  json['mimetype'] ??
                  json['contentType'] ??
                  _guessMimeType(resolvedUrl ?? objectKey))
              .toString(),
      size:
          (json['size'] as num?)?.toInt() ??
          (json['bytes'] as num?)?.toInt() ??
          0,
      mediaUrl: resolvedUrl,
    );
  }

  static String? _urlFromObjectKey(String objectKey) {
    final trimmed = objectKey.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return null;
  }

  static String _guessMimeType(String value) {
    final normalized = value.toLowerCase().split('?').first;
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.gif')) {
      return 'image/gif';
    }
    if (normalized.endsWith('.mp4')) {
      return 'video/mp4';
    }
    if (normalized.endsWith('.mov')) {
      return 'video/quicktime';
    }
    return 'image/jpeg';
  }
}
