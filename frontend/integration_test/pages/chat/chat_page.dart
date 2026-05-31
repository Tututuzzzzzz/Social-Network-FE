import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class ChatPage extends BasePage {
  ChatPage(super.tester);

  /// Điều hướng từ Feed tới màn hình Chat qua nút Chat ở thanh tiêu đề
  Future<void> navigateToChat() async {
    final chatButtonFinder = find.byKey(TestKeys.feedChatButton);
    if (chatButtonFinder.evaluate().isNotEmpty) {
      final chatIconButton = tester.widget<IconButton>(chatButtonFinder);
      chatIconButton.onPressed?.call();
      await tester.pumpAndSettle();
    }
  }

  /// Kiểm tra xem danh sách Chat có sẵn cuộc hội thoại nào chưa
  bool hasThreadItem() {
    return find.byKey(TestKeys.chatThreadItem(0)).evaluate().isNotEmpty;
  }

  /// Mở cuộc hội thoại đầu tiên trong danh sách chat
  Future<void> openFirstThread() async {
    await tap(find.byKey(TestKeys.chatThreadItem(0)), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  /// Nhấp vào nút để bắt đầu một cuộc hội thoại mới
  Future<void> openNewConversation() async {
    final newConvBtnFinder = find.byKey(TestKeys.chatNewConversationButton);
    await tap(newConvBtnFinder, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Chọn người bạn đầu tiên trong danh sách để nhắn tin
  Future<bool> selectFriendToChat() async {
    final friendFinder = find.byKey(TestKeys.newConversationFriend(0));
    final hasFriend = await tryWaitForFinder(
      friendFinder,
      timeout: const Duration(seconds: 5),
    );
    if (hasFriend) {
      await tap(friendFinder, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 4));
    }
    return hasFriend;
  }

  /// Soạn tin nhắn và bấm gửi
  Future<void> sendMessage(String text) async {
    await enterTextFieldText(TestKeys.messageInputField, text);
    await tap(find.byKey(TestKeys.messageSendButton), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  /// Quay lại danh sách Chat
  Future<void> goBackToChatList(String chatRoutePath) async {
    goRouterGo(chatRoutePath);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }


}
