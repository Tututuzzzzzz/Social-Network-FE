import 'package:equatable/equatable.dart';

import 'admin_post.dart';
import 'admin_post_comment.dart';

class AdminPostDetail extends Equatable {
  final AdminPost post;
  final List<AdminPostComment> comments;

  const AdminPostDetail({required this.post, required this.comments});

  int get rootCommentsCount => comments.length;

  int get totalCommentsCount {
    return comments.fold<int>(
      comments.length,
      (total, comment) => total + comment.descendantsCount,
    );
  }

  @override
  List<Object?> get props => [post, comments];
}
