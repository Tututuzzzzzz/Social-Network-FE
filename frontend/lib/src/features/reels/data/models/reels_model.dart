import '../../domain/entities/reels_entity.dart';

class ReelsModel extends ReelsEntity {
  const ReelsModel({
    required super.id,
    super.authorName,
    super.caption,
    super.mediaUrl,
    super.likesCount,
    super.commentsCount,
    super.minutesAgo,
  });

  factory ReelsModel.fromJson(Map<String, dynamic> json) {
    return ReelsModel(
      id: json['id']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'caption': caption,
    'mediaUrl': mediaUrl,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'minutesAgo': minutesAgo,
  };
}
