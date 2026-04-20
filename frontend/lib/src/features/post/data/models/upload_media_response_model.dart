import '../../domain/entities/post_media_entity.dart';
import 'post_media_model.dart';

class UploadMediaResponseModel {
  final String? message;
  final List<PostMediaModel> data;

  const UploadMediaResponseModel({this.message, this.data = const []});

  factory UploadMediaResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] ?? json['items'] ?? const [];

    final mediaItems = rawList is List
        ? rawList
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .map(PostMediaModel.fromJson)
              .toList()
        : <PostMediaModel>[];

    return UploadMediaResponseModel(
      message: json['message']?.toString(),
      data: mediaItems,
    );
  }

  List<PostMediaEntity> toEntities() {
    return data.map((item) => item.toEntity()).toList();
  }
}
