import '../entities/post_entity.dart';

List<PostEntity>? togglePostLikeInList({
  required List<PostEntity> posts,
  required String postId,
  required String currentUserId,
}) {
  var found = false;

  final updatedPosts = posts.map((post) {
    if (post.id != postId) {
      return post;
    }

    found = true;
    final likes = List<String>.from(post.likes);
    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
    } else {
      likes.add(currentUserId);
    }

    return post.copyWith(likes: likes);
  }).toList();

  return found ? updatedPosts : null;
}

List<PostEntity> replacePostInList(
  List<PostEntity> posts,
  PostEntity updatedPost,
) {
  var found = false;
  final updatedPosts = posts.map((post) {
    if (post.id != updatedPost.id) {
      return post;
    }

    found = true;
    return updatedPost;
  }).toList();

  return found ? updatedPosts : posts;
}
