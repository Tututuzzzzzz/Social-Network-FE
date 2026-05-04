import '../../../post/data/models/admin_post_model.dart';
import '../../../post/domain/entities/admin_post.dart';
import '../../domain/entities/admin_user_detail.dart';
import 'admin_user_model.dart';

class AdminUserDetailModel extends AdminUserDetail {
  const AdminUserDetailModel({required super.user, required super.posts});

  factory AdminUserDetailModel.fromResponses({
    required dynamic profileResponse,
    required dynamic postsResponse,
  }) {
    final profile = _profile(profileResponse);

    return AdminUserDetailModel(
      user: AdminUserModel.fromProfileJson(
        userJson: profile.userJson,
        statsJson: profile.statsJson,
      ),
      posts: _posts(postsResponse),
    );
  }

  static _ProfileParts _profile(dynamic response) {
    var userJson = <String, dynamic>{};
    var statsJson = <String, dynamic>{};

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];
      if (data is Map) {
        final dataMap = Map<String, dynamic>.from(data);
        final user = dataMap['user'];
        final stats = dataMap['stats'];
        if (user is Map) {
          userJson = Map<String, dynamic>.from(user);
        }
        if (stats is Map) {
          statsJson = Map<String, dynamic>.from(stats);
        }
      } else if (map['user'] is Map) {
        userJson = Map<String, dynamic>.from(map['user'] as Map);
      }
    }

    return _ProfileParts(userJson: userJson, statsJson: statsJson);
  }

  static List<AdminPost> _posts(dynamic response) {
    dynamic items = response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];
      if (data is Map) {
        items = data['items'] ?? data['data'];
      } else {
        items = data;
      }
    }

    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map((item) => AdminPostModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class _ProfileParts {
  final Map<String, dynamic> userJson;
  final Map<String, dynamic> statsJson;

  const _ProfileParts({required this.userJson, required this.statsJson});
}
