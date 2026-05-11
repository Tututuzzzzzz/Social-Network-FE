import 'dart:typed_data';

class MessageMediaUploadFile {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final String? mimeType;

  const MessageMediaUploadFile({
    required this.name,
    this.path,
    this.bytes,
    this.mimeType,
  });

  bool get hasBytes => bytes != null && bytes!.isNotEmpty;
  bool get hasPath => path != null && path!.trim().isNotEmpty;
}
