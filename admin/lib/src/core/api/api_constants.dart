class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'ADMIN_API_BASE_URL',
    defaultValue: '',
  );

  static const String login = '/auth/login';
  static const String postsFeed = '/posts/feed';
  static const String reports = '/reports';

  static String postById(String postId) => '/posts/$postId';

  static String postComments(String postId) => '/posts/$postId/comments';

  static String userProfile(String userId) => '/users/$userId/profile';

  static String userPosts(String userId) => '/users/$userId/posts';

  static String reportById(String reportId) => '/reports/$reportId';
}
