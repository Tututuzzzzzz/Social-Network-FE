import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    super.kind,
    super.category,
    super.title,
    super.subtitle,
    super.handle,
    super.mutualFriends,
    super.isOnline,
    super.iconKey,
    super.mediaUrl,
    super.likesCount,
    super.commentsCount,
    super.minutesAgo,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'item',
      category: json['category']?.toString() ?? 'all',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      handle: json['handle']?.toString() ?? '',
      mutualFriends: (json['mutualFriends'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] == true,
      iconKey: json['iconKey']?.toString() ?? 'circle',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'category': category,
    'title': title,
    'subtitle': subtitle,
    'handle': handle,
    'mutualFriends': mutualFriends,
    'isOnline': isOnline,
    'iconKey': iconKey,
    'mediaUrl': mediaUrl,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'minutesAgo': minutesAgo,
  };
}
