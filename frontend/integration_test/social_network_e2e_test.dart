import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
import 'tests/friends_e2e_test.dart';
import 'tests/notifications_e2e_test.dart';
import 'tests/chat_e2e_test.dart';
import 'tests/profile_e2e_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: register (optional) + login + core flows',
      (WidgetTester tester) async {
    // 1. Kiểm tra cấu hình môi trường cốt lõi trước khi thực thi
    TestConfig.validateCoreEnvironment();

    // 2. Reset database backend để đảm bảo môi trường E2E sạch hoàn toàn
    await TestConfig.resetDatabase();

    // 3. Dọn dẹp Hive local storage cũ trên Emulator
    try {
      print('🧹 [E2E] Đang dọn dẹp Hive local storage trên Emulator...');
      await Hive.initFlutter();
      await Hive.deleteFromDisk();
      print('✅ [E2E] Dọn dẹp Hive local storage thành công!');
    } catch (e) {
      print('⚠️ [E2E] Lỗi khi dọn dẹp Hive local storage: $e');
    }

    // 4. Khởi động và tải giao diện ứng dụng (Pump)
    await TestConfig.pumpApp(tester);

    // 5. Khởi tạo các trang theo mô hình Page Object Model (POM)
    final registerPage = RegisterPage(tester);
    final loginPage = LoginPage(tester);
    final feedPage = FeedPage(tester);
    final searchPage = SearchPage(tester);
    final createPostPage = CreatePostPage(tester);
    final chatPage = ChatPage(tester);
    final profilePage = ProfilePage(tester);

    // 6. Khai báo Map chia sẻ session dữ liệu giữa các luồng test
    final sessionData = <String, String>{};

    // 7. Thực thi tuần tự với error isolation + screenshot
    await _runFlow('Auth', () =>
      runAuthFlow(tester, registerPage, loginPage, sessionData),
      binding,
    );

    final currentUsername = sessionData['username']!;

    await _runFlow('Feed', () =>
      runFeedFlow(tester, feedPage, searchPage, createPostPage, currentUsername),
      binding,
    );

    await _runFlow('Friends', () =>
      runFriendsFlow(tester, feedPage, searchPage),
      binding,
    );

    await _runFlow('Notifications', () =>
      runNotificationsFlow(tester, feedPage),
      binding,
    );

    await _runFlow('Chat', () =>
      runChatFlow(tester, chatPage),
      binding,
    );

    await _runFlow('Profile', () =>
      runProfileFlow(tester, profilePage, loginPage),
      binding,
    );
  });
}

/// Wrapper: log flow name, chụp screenshot nếu fail, rethrow để fail test
Future<void> _runFlow(
  String name,
  Future<void> Function() flow,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  print('');
  print('═══════════════════════════════════════');
  print('🚀 [E2E] Bắt đầu luồng: $name');
  print('═══════════════════════════════════════');
  final stopwatch = Stopwatch()..start();

  try {
    await flow();
    stopwatch.stop();
    print('✅ [E2E] Luồng $name PASSED (${stopwatch.elapsedMilliseconds}ms)');
  } catch (e) {
    stopwatch.stop();
    print('❌ [E2E] Luồng $name FAILED sau ${stopwatch.elapsedMilliseconds}ms');
    print('   Lỗi: $e');

    // Chụp screenshot tại thời điểm fail
    try {
      await binding.takeScreenshot('failure_${name.toLowerCase()}');
      print('📸 [E2E] Đã chụp screenshot: failure_${name.toLowerCase()}');
    } catch (screenshotError) {
      print('⚠️ [E2E] Không thể chụp screenshot: $screenshotError');
    }

    rethrow; // Vẫn fail test — screenshot chỉ để debug
  }
}
