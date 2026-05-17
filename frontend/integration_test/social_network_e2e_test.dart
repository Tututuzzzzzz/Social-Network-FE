import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'core/test_config.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/feed/feed_page.dart';
import 'pages/feed/create_post_page.dart';
import 'pages/search/search_page.dart';
import 'pages/chat/chat_page.dart';
import 'pages/profile/profile_page.dart';

import 'tests/auth_e2e_test.dart';
import 'tests/feed_e2e_test.dart';
import 'tests/chat_e2e_test.dart';
import 'tests/profile_e2e_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: register (optional) + login + core flows',
      (WidgetTester tester) async {
    // 1. Kiểm tra cấu hình môi trường cốt lõi trước khi thực thi
    TestConfig.validateCoreEnvironment();

    // 2. Khởi động và tải giao diện ứng dụng (Pump)
    await TestConfig.pumpApp(tester);

    // 3. Khởi tạo các trang theo mô hình Page Object Model (POM)
    final registerPage = RegisterPage(tester);
    final loginPage = LoginPage(tester);
    final feedPage = FeedPage(tester);
    final searchPage = SearchPage(tester);
    final createPostPage = CreatePostPage(tester);
    final chatPage = ChatPage(tester);
    final profilePage = ProfilePage(tester);

    // 4. Khai báo Map chia sẻ session dữ liệu giữa các luồng test
    final sessionData = <String, String>{};

    // 5. Thực thi tuần tự 4 tầng kịch bản nghiệp vụ E2E
    
    // Tầng A: Đăng ký & Đăng nhập
    await runAuthFlow(tester, registerPage, loginPage, sessionData);

    final currentUsername = sessionData['username']!;

    // Tầng B: Tương tác Feed (Like, Comment, Search, Post)
    await runFeedFlow(tester, feedPage, searchPage, createPostPage, currentUsername);

    // Tầng C: Nhắn tin Socket qua Chat Room
    await runChatFlow(tester, chatPage);

    // Tầng D: Sửa Bio Hồ sơ & Đăng xuất
    await runProfileFlow(tester, profilePage, loginPage);
  });
}
