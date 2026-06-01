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
      // Chờ màn hình Chat load xong (nút tạo cuộc hội thoại xuất hiện)
      await waitForKey(TestKeys.chatNewConversationButton);
    }
  }

  /// Kiểm tra xem danh sách Chat có sẵn cuộc hội thoại nào chưa
  bool hasThreadItem() {
    return find.byKey(TestKeys.chatThreadItem(0)).evaluate().isNotEmpty;
  }

  /// Mở cuộc hội thoại đầu tiên trong danh sách chat
  Future<void> openFirstThread() async {
    await tap(find.byKey(TestKeys.chatThreadItem(0)), warnIfMissed: false);
    // Chờ khung nhập tin nhắn xuất hiện thay vì delay cứng 4s
    await waitForKey(TestKeys.messageInputField);
  }

  /// Nhấp vào nút để bắt đầu một cuộc hội thoại mới
  Future<void> openNewConversation() async {
    final newConvBtnFinder = find.byKey(TestKeys.chatNewConversationButton);
    await tap(newConvBtnFinder, warnIfMissed: false);
    // Chờ danh sách bạn bè (hoặc empty state) xuất hiện thay vì delay cứng 2s
    await tester.pumpAndSettle();
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
      // Chờ khung nhập tin nhắn xuất hiện thay vì delay cứng 4s
      await waitForKey(TestKeys.messageInputField);
    }
    return hasFriend;
  }

  /// Soạn tin nhắn và bấm gửi
  Future<void> sendMessage(String text) async {
    await enterTextFieldText(TestKeys.messageInputField, text);
    await tap(find.byKey(TestKeys.messageSendButton), warnIfMissed: false);
    // Chờ trường input xuất hiện trở lại (sau khi gửi xong) thay vì delay cứng 4s
    await waitForKey(TestKeys.messageInputField);
  }

  /// Quay lại danh sách Chat
  Future<void> goBackToChatList(String chatRoutePath) async {
    goRouterGo(chatRoutePath);
    // Chờ nút tạo cuộc hội thoại mới xuất hiện thay vì delay cứng 2s
    await waitForKey(TestKeys.chatNewConversationButton);
  }
}
