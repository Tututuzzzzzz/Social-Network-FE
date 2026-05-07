import '../config/env_config.dart';

/// Tất cả API endpoint paths — KHÔNG thay đổi theo môi trường.
///
/// URL đầy đủ = [EnvConfig.instance.apiBaseUrl] + path bên dưới.
/// Ví dụ: `http://localhost:3001/api` + `/auth/login`
class ApiConstants {
  ApiConstants._();

  /// Base URL lấy từ EnvConfig (thay đổi theo .env file).
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // ── Auth ─────────────────────────────────────────────

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';

  // ── Friends ──────────────────────────────────────────

  static const String friends = '/friends';
  static const String friendsRequests = '/friends/requests';

  static String friendRequestAccept(String requestId) =>
      '/friends/requests/$requestId/accept';
  static String friendRequestReject(String requestId) =>
      '/friends/requests/$requestId/reject';

  // ── Users / Profile ──────────────────────────────────

  static const String profile = '/users/me';
  static const String profileAvatar = '/users/me/avatar';
  static const String usersSearch = '/users/search';
  static const String usersStatus = '/users/status';

  static String userProfile(String userId) => '/users/$userId/profile';
  static String userPosts(String userId, {int page = 1, int limit = 20}) =>
      '/users/$userId/posts?page=$page&limit=$limit';

  // ── Conversations ────────────────────────────────────

  static const String conversations = '/conversations';

  // ── Messages ─────────────────────────────────────────

  static const String messages = '/messages/direct';
  static const String groups = '/messages/group';
  static const String messagesDirectText = '/messages/direct/text';
  static const String messagesDirectMedia = '/messages/direct/media';
  static const String messagesGroupText = '/messages/group/text';
  static const String messagesGroupMedia = '/messages/group/media';

  static String messageReaction(String messageId) =>
      '/messages/$messageId/reaction';
  static String messageRead(String conversationId, String messageId) =>
      '/messages/$conversationId/messages/$messageId/read';
  static String messagesReadAll(String conversationId) =>
      '/messages/$conversationId/messages/read-all';

  static String messagesHistory(
    String conversationId, {
    int limit = 30,
    String? cursor,
  }) {
    final queryParameters = <String, String>{'limit': '$limit'};
    final normalizedCursor = cursor?.trim() ?? '';
    if (normalizedCursor.isNotEmpty) {
      queryParameters['cursor'] = normalizedCursor;
    }

    final query = Uri(queryParameters: queryParameters).query;
    return '/messages/$conversationId/messages?$query';
  }

  // ── Posts ─────────────────────────────────────────────

  static const String posts = '/posts';
  static const String postsFeed = '/posts/feed';

  static String postById(String postId) => '/posts/$postId';
  static String postLike(String postId) => '/posts/$postId/like';
  static String postReport(String postId) => '/posts/$postId/report';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';

  // ── Notifications ────────────────────────────────────

  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';

  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  // ── Admin ────────────────────────────────────────────

  static const String adminReports = '/admin/reports';

  static String adminReportsByPost(String postId) =>
      '/admin/reports/post/$postId';
  static String adminPostHide(String postId) =>
      '/admin/posts/$postId/hide';
  static String adminPostRestore(String postId) =>
      '/admin/posts/$postId/restore';
  static String adminPostDelete(String postId) =>
      '/admin/posts/$postId';
  static String adminReportReview(String reportId) =>
      '/admin/reports/$reportId';
}
