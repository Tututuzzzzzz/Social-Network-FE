import 'package:equatable/equatable.dart';

class ReelsEntity extends Equatable {
  final String id;
  final String authorName;
  final String caption;
  final String mediaUrl;
  final int likesCount;
  final int commentsCount;
  final int minutesAgo;

  const ReelsEntity({
    required this.id,
    this.authorName = '',
    this.caption = '',
    this.mediaUrl = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.minutesAgo = 0,
  });

  @override
  List<Object?> get props => [
    id,
    authorName,
    caption,
    mediaUrl,
    likesCount,
    commentsCount,
    minutesAgo,
  ];
}
