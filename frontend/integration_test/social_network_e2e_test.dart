import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'core/test_config.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/chat/chat_page.dart';
import 'pages/feed/create_post_page.dart';
import 'pages/feed/feed_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/search/search_page.dart';
import 'tests/auth_e2e_test.dart';
import 'tests/chat_e2e_test.dart';
import 'tests/feed_e2e_test.dart';
import 'tests/friends_e2e_test.dart';
import 'tests/notifications_e2e_test.dart';
import 'tests/profile_e2e_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: seeded login + core social flows', (
    WidgetTester tester,
  ) async {
    TestConfig.validateCoreEnvironment();

    E2ESeedData? seedData;
    try {
      seedData = await TestConfig.seedDatabase();

      try {
        debugPrint('[E2E] Clearing Hive local storage...');
        await Hive.initFlutter();
        await Hive.deleteFromDisk();
        debugPrint('[E2E] Hive local storage cleared.');
      } catch (error) {
        debugPrint('[E2E] Failed to clear Hive local storage: $error');
      }

      await TestConfig.pumpApp(tester);

      final registerPage = RegisterPage(tester);
      final loginPage = LoginPage(tester);
      final feedPage = FeedPage(tester);
      final searchPage = SearchPage(tester);
      final createPostPage = CreatePostPage(tester);
      final chatPage = ChatPage(tester);
      final profilePage = ProfilePage(tester);
      final sessionData = <String, String>{};

      await runAuthFlow(
        tester,
        registerPage,
        loginPage,
        sessionData,
        seedData: seedData,
      );

      final currentUsername = sessionData['username']!;

      await runFeedFlow(
        tester,
        feedPage,
        searchPage,
        createPostPage,
        currentUsername,
      );

      if (TestConfig.enableMediaUpload) {
        await runFeedMediaUploadFlow(tester, feedPage, createPostPage);
      }

      await runFriendsFlow(
        tester,
        feedPage,
        searchPage,
        targetUsername: seedData.admin.username,
      );

      await runNotificationsFlow(tester, feedPage);
      await runChatFlow(tester, chatPage);
      await runProfileFlow(tester, profilePage, loginPage);
    } finally {
      await TestConfig.resetDatabase(throwOnFailure: false);
      if (seedData != null) {
        debugPrint('[E2E] Cleaned database for runId=${seedData.runId}');
      }
    }
  });
}
