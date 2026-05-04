import 'package:equatable/equatable.dart';

class AdminPostMedia extends Equatable {
  final String bucket;
  final String objectKey;
  final String mimeType;
  final int size;
  final String? mediaUrl;

  const AdminPostMedia({
    required this.bucket,
    required this.objectKey,
    required this.mimeType,
    required this.size,
    this.mediaUrl,
  });

  bool get hasUrl => mediaUrl != null && mediaUrl!.trim().isNotEmpty;

  bool get isImage => mimeType.toLowerCase().startsWith('image/');

  @override
  List<Object?> get props => [bucket, objectKey, mimeType, size, mediaUrl];
}
