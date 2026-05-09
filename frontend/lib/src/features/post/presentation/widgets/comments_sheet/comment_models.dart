import 'package:frontend/src/features/post/domain/entities/post_comment_entity.dart';

class FlattenedComment {
  const FlattenedComment({required this.comment, required this.depth});

  final PostCommentEntity comment;
  final int depth;
}

class CommentRemovalResult {
  const CommentRemovalResult({required this.remaining, required this.removedIds});

  final List<PostCommentEntity> remaining;
  final Set<String> removedIds;
}

List<FlattenedComment> buildFlattenedComments(List<PostCommentEntity> comments) {
  if (comments.isEmpty) {
    return const [];
  }

  final sorted = List<PostCommentEntity>.from(comments)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final allIds = sorted.map((item) => item.id).toSet();

  final Map<String, List<PostCommentEntity>> byParent = {};
  final roots = <PostCommentEntity>[];

  for (final comment in sorted) {
    final parentId = comment.parentCommentId;
    if (parentId == null || parentId.isEmpty || !allIds.contains(parentId)) {
      roots.add(comment);
      continue;
    }
    byParent.putIfAbsent(parentId, () => []).add(comment);
  }

  final result = <FlattenedComment>[];
  final visited = <String>{};

  void appendComment(PostCommentEntity comment, int depth) {
    if (visited.contains(comment.id)) {
      return;
    }

    visited.add(comment.id);
    result.add(FlattenedComment(comment: comment, depth: depth));

    final children = byParent[comment.id] ?? const <PostCommentEntity>[];
    for (final child in children) {
      appendComment(child, depth + 1);
    }
  }

  for (final root in roots) {
    appendComment(root, 0);
  }

  if (result.length != sorted.length) {
    for (final comment in sorted) {
      if (!visited.contains(comment.id)) {
        appendComment(comment, 0);
      }
    }
  }

  return result;
}

CommentRemovalResult removeCommentThread(
  List<PostCommentEntity> comments,
  String commentId,
) {
  final removedIds = <String>{commentId};
  var didAdd = true;

  while (didAdd) {
    didAdd = false;
    for (final comment in comments) {
      if (removedIds.contains(comment.id)) continue;
      final parentId = comment.parentCommentId;
      if (parentId != null && parentId.isNotEmpty) {
        if (removedIds.contains(parentId)) {
          removedIds.add(comment.id);
          didAdd = true;
        }
      }
    }
  }

  final remaining = comments.where((comment) => !removedIds.contains(comment.id)).toList();
  return CommentRemovalResult(remaining: remaining, removedIds: removedIds);
}

PostCommentEntity mergeUpdatedComment(
  PostCommentEntity current,
  PostCommentEntity updated,
  String fallbackContent,
) {
  final content = updated.content.trim().isNotEmpty ? updated.content : fallbackContent;

  return PostCommentEntity(
    id: current.id,
    parentCommentId: updated.parentCommentId ?? current.parentCommentId,
    authorId: updated.authorId.isNotEmpty ? updated.authorId : current.authorId,
    authorUsername: updated.authorUsername ?? current.authorUsername,
    authorDisplayName: updated.authorDisplayName ?? current.authorDisplayName,
    authorAvatarUrl: updated.authorAvatarUrl ?? current.authorAvatarUrl,
    content: content,
    createdAt: current.createdAt,
    updatedAt: updated.updatedAt,
  );
}
