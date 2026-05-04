import 'package:equatable/equatable.dart';

import 'post_comment_entity.dart';

class PostCommentsEntity extends Equatable {
  final List<PostCommentEntity> comments;
  final int commentsCount;

  const PostCommentsEntity({this.comments = const [], this.commentsCount = 0});

  @override
  List<Object?> get props => [comments, commentsCount];
}
