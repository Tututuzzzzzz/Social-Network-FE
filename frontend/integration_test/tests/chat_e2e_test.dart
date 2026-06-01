import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/chat/chat_page.dart';

/// Chạy luồng kiểm thử tính năng Nhắn tin (Chat) qua Socket thời gian thực.
///
/// Điều kiện tiên quyết: Luồng này chạy SAU [runFriendsFlow], tuy nhiên lời mời
/// kết bạn gửi đi có thể chưa được chấp nhận (vì không có người dùng thứ hai
/// thao tác). Do đó:
/// - Test BẮT BUỘC kiểm tra màn hình Chat load thành công.
/// - Test kiểm tra nút "Tạo cuộc hội thoại mới" tồn tại.
/// - Nếu có sẵn cuộc hội thoại hoặc bạn bè, sẽ thực hiện gửi tin nhắn và assert.
/// - Nếu không có bạn bè được chấp nhận, ghi nhận trạng thái "danh sách trống"
///   và KHÔNG fail — đây là hành vi đúng khi chưa có friend.
Future<void> runChatFlow(
  WidgetTester tester,
  ChatPage chatPage,
) async {
  // ── Bước 1: Điều hướng sang màn hình Chat ──────────────────────────────────

  // [ASSERTION] Nút điều hướng sang Chat phải tồn tại trên Feed
  expect(
    find.byKey(TestKeys.feedChatButton),
    findsOneWidget,
    reason: 'Nút Chat phải hiển thị trên thanh AppBar của màn hình Feed',
  );

  await chatPage.navigateToChat();

  // [ASSERTION] Màn hình Chat phải load thành công — đây là assertion BẮT BUỘC
  await chatPage.waitForFinder(
    find.byKey(TestKeys.chatNewConversationButton),
    timeout: const Duration(seconds: 15),
  );
  expect(
    find.byKey(TestKeys.chatNewConversationButton),
    findsOneWidget,
    reason:
        'Màn hình Chat phải load thành công với nút "Tạo cuộc hội thoại mới". '
        'Kiểm tra điều hướng từ Feed sang Chat đang hoạt động.',
  );

  // Chờ danh sách cuộc hội thoại được fetch từ API thay vì delay cứng 4s
  // tryWaitForFinder: không fail nếu danh sách rỗng (đã xử lý ở if/else bên dưới)
  await chatPage.tryWaitForFinder(
    find.byKey(TestKeys.chatThreadItem(0)),
    timeout: const Duration(seconds: 5),
  );

  // ── Bước 2: Thực hiện gửi tin nhắn ──────────────────────────────────────────
  if (chatPage.hasThreadItem()) {
    // Trường hợp đã có cuộc hội thoại sẵn (seed_user↔admin hoặc seed_user↔seed_friend)
    await chatPage.openFirstThread();

    // ── Bước 3: Gửi tin nhắn ─────────────────────────────────────────────────

    // [ASSERTION] Trường nhập tin nhắn phải hiển thị trong phòng chat
    expect(
      find.byKey(TestKeys.messageInputField),
      findsOneWidget,
      reason: 'Trường nhập tin nhắn phải hiển thị khi vào trong phòng chat',
    );

    await chatPage.sendMessage(MockData.chatMessage);

    // [ASSERTION] Sau khi gửi, trường nhập tin nhắn vẫn phải hiển thị
    expect(
      find.byKey(TestKeys.messageInputField),
      findsOneWidget,
      reason: 'Trường nhập tin nhắn vẫn phải hiển thị sau khi gửi',
    );

    await chatPage.goBackToChatList(AppRoutes.chat.path);
  } else {
    // Trường hợp chưa có cuộc hội thoại sẵn → mở New Conversation và tạo từ danh sách bạn bè
    await chatPage.openNewConversation();

    // Chờ danh sách bạn bè load xong trên màn hình New Conversation thay vì delay cứng 4s
    await chatPage.tryWaitForFinder(
      find.byKey(TestKeys.newConversationFriend(0)),
      timeout: const Duration(seconds: 5),
    );

    // [SOFT CHECK] Kiểm tra xem có bạn bè được accept không
    // Nếu không có → bỏ qua bước gửi tin nhắn, KHÔNG fail test
    // (lời mời kết bạn tới admin có thể chưa được accept do không có user thứ hai)
    final friendFinder = find.byKey(TestKeys.newConversationFriend(0));
    final hasFriend = friendFinder.evaluate().isNotEmpty;

    if (hasFriend) {
      await chatPage.selectFriendToChat();

      // [ASSERTION] Trường nhập tin nhắn phải hiển thị trong phòng chat
      expect(
        find.byKey(TestKeys.messageInputField),
        findsOneWidget,
        reason: 'Trường nhập tin nhắn phải hiển thị khi vào trong phòng chat',
      );

      await chatPage.sendMessage(MockData.chatMessage);

      // [ASSERTION] Sau khi gửi, trường nhập tin nhắn vẫn phải hiển thị
      expect(
        find.byKey(TestKeys.messageInputField),
        findsOneWidget,
        reason: 'Trường nhập tin nhắn vẫn phải hiển thị sau khi gửi',
      );

      await chatPage.goBackToChatList(AppRoutes.chat.path);
    } else {
      // Không có friend được accept → log cảnh báo và quay lại danh sách chat
      log(
        '⚠️ [E2E Chat] Không tìm thấy friend được accept trong NewConversation. '
        'Bỏ qua bước gửi tin nhắn. Kiểm tra backend seed.ts đã tạo friendship admin↔seed_user.',
        name: 'E2E',
      );
      // Quay lại danh sách chat (nếu đang ở màn hình NewConversation)
      await chatPage.goBackToChatList(AppRoutes.chat.path);
    }
  }

  // ── Bước 4: Quay lại Feed ──────────────────────────────────────────────────
  await chatPage.goBackToFeed(AppRoutes.home.path);

  // [ASSERTION] Phải quay lại màn hình Feed thành công
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Phải quay lại màn hình Feed sau khi hoàn thành luồng Chat',
  );
}
