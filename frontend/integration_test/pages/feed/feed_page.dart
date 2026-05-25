import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import '../../core/base_page.dart';

class FeedPage extends BasePage {
  FeedPage(super.tester);

  /// Thích bài đăng đầu tiên trên bảng tin
  Future<void> likeFirstPost() async {
    final likeButtonFinder = find.byKey(TestKeys.postLikeButton);
    if (likeButtonFinder.evaluate().isNotEmpty) {
      await safeTap(likeButtonFinder.first, warnIfMissed: true);
    }
  }

  /// Mở rộng Bottom Sheet bình luận của bài viết đầu tiên
  Future<void> openCommentSection() async {
    final commentButtonFinder = find.byKey(TestKeys.postCommentButton);
    if (commentButtonFinder.evaluate().isNotEmpty) {
      await safeTap(commentButtonFinder.first, warnIfMissed: true);
      await waitAndSettle(find.byKey(TestKeys.postCommentTextField));
    }
  }

  /// Nhập văn bản bình luận
  Future<void> writeComment(String commentText) async {
    await enterTextFieldText(TestKeys.postCommentTextField, commentText);
  }

  /// Gửi bình luận đi
  Future<void> submitComment() async {
    final sendButton = find.byKey(TestKeys.postCommentSendButton);
    await safeTap(sendButton, warnIfMissed: true);
  }

  /// Đóng Bottom Sheet bình luận
  Future<void> closeCommentSection() async {
    final commentInputCtx = tester.element(find.byKey(TestKeys.postCommentTextField));
    Navigator.of(commentInputCtx).pop();
    await tester.pumpAndSettle();
  }

  /// Nhấp vào biểu tượng Tìm kiếm trên bảng tin
  Future<void> navigateToSearch() async {
    final searchButtonFinder = find.byKey(TestKeys.feedSearchButton);
    if (searchButtonFinder.evaluate().isNotEmpty) {
      await safeTap(searchButtonFinder, warnIfMissed: true);
    }
  }

  /// Nhấp vào biểu tượng Trò chuyện trên bảng tin
  Future<void> navigateToChat() async {
    final chatButtonFinder = find.byKey(TestKeys.feedChatButton);
    if (chatButtonFinder.evaluate().isNotEmpty) {
      await safeTap(chatButtonFinder, warnIfMissed: true);
    }
  }
}
