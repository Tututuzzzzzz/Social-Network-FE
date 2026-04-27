class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'ADMIN_API_BASE_URL',
    defaultValue: '',
  );

  static const String login = '/auth/login';
  static const String postsFeed = '/posts/feed';

  static String postById(String postId) => '/posts/$postId';
}
