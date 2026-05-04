import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String id;
  final String kind;
  final String category;
  final String title;
  final String subtitle;
  final String handle;
  final int mutualFriends;
  final bool isOnline;
  final String iconKey;
  final String mediaUrl;
  final int likesCount;
  final int commentsCount;
  final int minutesAgo;
  final String authorId;

  const HomeEntity({
    required this.id,
    this.authorId = '',
    this.kind = 'item',
    this.category = 'all',
    this.title = '',
    this.subtitle = '',
    this.handle = '',
    this.mutualFriends = 0,
    this.isOnline = false,
    this.iconKey = 'circle',
    this.mediaUrl = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.minutesAgo = 0,
  });

  @override
  List<Object?> get props => [
    id,
    kind,
    category,
    title,
    subtitle,
    handle,
    mutualFriends,
    isOnline,
    iconKey,
    mediaUrl,
    likesCount,
    commentsCount,
    minutesAgo,
    authorId,
  ];
}
