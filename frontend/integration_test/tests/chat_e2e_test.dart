import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/chat/chat_page.dart';

/// Chạy luồng Nhắn tin Socket thời gian thực
Future<void> runChatFlow(
  WidgetTester tester,
  ChatPage chatPage,
) async {
  await chatPage.navigateToChat();
  await chatPage.ensureOnPage(TestKeys.chatNewConversationButton, AppRoutes.chat.path);

  bool chatFlowExecuted = false;
  if (chatPage.hasThreadItem()) {
    await chatPage.openFirstThread();
    chatFlowExecuted = true;
  } else {
    await chatPage.openNewConversation();
    final hasFriend = await chatPage.selectFriendToChat();
    if (hasFriend) {
      chatFlowExecuted = true;
    } else {
      await chatPage.goBackToChatList(AppRoutes.chat.path);
    }
  }

  if (chatFlowExecuted) {
    await chatPage.sendMessage(MockData.chatMessage);
    await chatPage.goBackToChatList(AppRoutes.chat.path);
  }

  await chatPage.goBackToFeed(AppRoutes.home.path);

  // [ASSERTION] Đảm bảo đã quay lại màn hình Feed
  expect(find.byKey(TestKeys.feedSearchButton), findsOneWidget);
}
