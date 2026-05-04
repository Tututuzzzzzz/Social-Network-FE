import 'package:equatable/equatable.dart';

class PostMediaEntity extends Equatable {
  final String bucket;
  final String objectKey;
  final String? mediaUrl;
  final String mimeType;
  final int size;

  const PostMediaEntity({
    required this.bucket,
    required this.objectKey,
    this.mediaUrl,
    required this.mimeType,
    required this.size,
  });

  @override
  List<Object?> get props => [bucket, objectKey, mediaUrl, mimeType, size];
}
