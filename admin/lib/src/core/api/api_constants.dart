class ApiConstants {
  static const String baseUrl = 'ADMIN_API_BASE_URL';

  static const String login = '/auth/login';
  static const String postsFeed = '/posts/feed';
  static const String reports = '/admin/reports';

  static String postById(String postId) => '/posts/$postId';

  static String adminPostHide(String postId) => '/admin/posts/$postId/hide';

  static String adminPostRestore(String postId) =>
      '/admin/posts/$postId/restore';

  static String adminPostDelete(String postId) => '/admin/posts/$postId';

  static String postComments(String postId) => '/posts/$postId/comments';

  static String userProfile(String userId) => '/users/$userId/profile';

  static String userPosts(String userId) => '/users/$userId/posts';

  static String reportsByPost(String postId) => '/admin/reports/post/$postId';

  static String reportById(String reportId) => '/admin/reports/$reportId';
}
