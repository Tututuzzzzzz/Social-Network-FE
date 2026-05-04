import '../../domain/entities/admin_post_comment.dart';
import '../../domain/entities/admin_post_detail.dart';
import 'admin_post_comment_model.dart';
import 'admin_post_model.dart';

class AdminPostDetailModel extends AdminPostDetail {
  const AdminPostDetailModel({required super.post, required super.comments});

  factory AdminPostDetailModel.fromResponses({
    required Map<String, dynamic> postJson,
    required dynamic commentsResponse,
  }) {
    return AdminPostDetailModel(
      post: AdminPostModel.fromJson(postJson),
      comments: _comments(commentsResponse),
    );
  }

  static List<AdminPostComment> _comments(dynamic response) {
    dynamic comments = response;

    if (response is Map) {
      final responseMap = Map<String, dynamic>.from(response);
      final data = responseMap['data'];
      if (data is Map) {
        comments = data['comments'] ?? data['items'] ?? data['data'];
      } else {
        comments = data;
      }
    }

    if (comments is! List) {
      return const [];
    }

    return comments
        .whereType<Map>()
        .map(
          (item) =>
              AdminPostCommentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
