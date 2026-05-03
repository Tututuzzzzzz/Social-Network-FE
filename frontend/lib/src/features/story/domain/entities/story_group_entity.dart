import 'package:equatable/equatable.dart';
import 'story_item_entity.dart';

class StoryGroupEntity extends Equatable {
  final String userId;
  final String username;
  final String avatarUrl;
  final List<StoryItemEntity> stories;

  const StoryGroupEntity({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.stories,
  });

  @override
  List<Object?> get props => [userId, username, avatarUrl, stories];
}
