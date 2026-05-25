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
      await safeTap(chatButtonFinder, warnIfMissed: true);
    }
  }

  /// Kiểm tra xem danh sách Chat có sẵn cuộc hội thoại nào chưa
  bool hasThreadItem() {
    return find.byKey(TestKeys.chatThreadItem(0)).evaluate().isNotEmpty;
  }

  /// Mở cuộc hội thoại đầu tiên trong danh sách chat
  Future<void> openFirstThread() async {
    await safeTap(find.byKey(TestKeys.chatThreadItem(0)), warnIfMissed: true);
  }

  /// Nhấp vào nút để bắt đầu một cuộc hội thoại mới
  Future<void> openNewConversation() async {
    final newConvBtnFinder = find.byKey(TestKeys.chatNewConversationButton);
    await safeTap(newConvBtnFinder, warnIfMissed: true);
  }

  /// Chọn người bạn đầu tiên trong danh sách để nhắn tin
  Future<bool> selectFriendToChat() async {
    final friendFinder = find.byKey(TestKeys.newConversationFriend(0));
    final hasFriend = await tryWaitForFinder(
      friendFinder,
      timeout: const Duration(seconds: 5),
    );
    if (hasFriend) {
      await safeTap(friendFinder, warnIfMissed: true);
    }
    return hasFriend;
  }

  /// Soạn tin nhắn và bấm gửi
  Future<void> sendMessage(String text) async {
    await enterTextFieldText(TestKeys.messageInputField, text);
    await safeTap(find.byKey(TestKeys.messageSendButton), warnIfMissed: true);
  }

  /// Quay lại danh sách Chat
  Future<void> goBackToChatList(String chatRoutePath) async {
    goRouterGo(chatRoutePath);
    await tester.pumpAndSettle();
  }

  /// Quay lại trang chủ Bảng tin từ màn hình danh sách Chat
  Future<void> goBackToFeed(String homeRoutePath) async {
    goRouterGo(homeRoutePath);
    await tester.pumpAndSettle();
  }
}
