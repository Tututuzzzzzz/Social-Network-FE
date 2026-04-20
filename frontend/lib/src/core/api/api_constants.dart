import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    // Android emulator cannot reach host services via localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://localhost:3001/api';
    }
    return 'http://localhost:3001/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String friends = '/friends';
  static const String friendsRequests = '/friends/requests';
  static const String profile = '/users/me';
  static const String profileAvatar = '/users/me/avatar';
  static const String conversations = '/conversations';
  static const String messages = '/messages/direct';
  static const String groups = '/messages/group';
  static const String messagesDirectText = '/messages/direct/text';
  static const String messagesDirectMedia = '/messages/direct/media';
  static const String messagesGroupText = '/messages/group/text';
  static const String messagesGroupMedia = '/messages/group/media';
  static const String posts = '/posts';
  static const String postsFeed = '/posts/feed';
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';

  static String postById(String postId) => '/posts/$postId';
  static String postLike(String postId) => '/posts/$postId/like';
  static String postReport(String postId) => '/posts/$postId/report';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';
  static String userProfile(String userId) => '/users/$userId/profile';
  static String userPosts(String userId, {int page = 1, int limit = 20}) =>
      '/users/$userId/posts?page=$page&limit=$limit';
  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  // Messages endpoints
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

  // Friend requests endpoints
  static String friendRequestAccept(String requestId) =>
      '/friends/requests/$requestId/accept';
  static String friendRequestReject(String requestId) =>
      '/friends/requests/$requestId/reject';

  // // User posts endpoints
  // static String userPostById(String userId, String postId) =>
  //     '/users/$userId/posts/$postId';
}
