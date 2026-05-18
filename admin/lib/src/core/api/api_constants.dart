class ApiConstants {
  static const String _apiScheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: '',
  );
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );
  static const String _apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '',
  );
  static const String _apiBasePath = String.fromEnvironment(
    'API_BASE_PATH',
    defaultValue: '/api',
  );

  static String get baseUrl {
    if (_apiHost.isEmpty) {
      return '';
    }

    final scheme = _apiScheme.isEmpty ? 'http' : _apiScheme;
    final portSuffix = _apiPort.isEmpty ? '' : ':$_apiPort';
    final normalizedBasePath = _apiBasePath.isEmpty
        ? ''
        : (_apiBasePath.startsWith('/') ? _apiBasePath : '/$_apiBasePath');
    return '$scheme://$_apiHost$portSuffix$normalizedBasePath';
  }

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
