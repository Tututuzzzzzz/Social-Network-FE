import 'package:equatable/equatable.dart';

import '../../../post/domain/entities/admin_post.dart';
import 'admin_user.dart';

class AdminUserDetail extends Equatable {
  final AdminUser user;
  final List<AdminPost> posts;

  const AdminUserDetail({required this.user, required this.posts});

  @override
  List<Object?> get props => [user, posts];
}
