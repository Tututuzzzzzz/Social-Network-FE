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
      final likeInkWell = tester.widget<InkWell>(
        find.descendant(
          of: likeButtonFinder.first,
          matching: find.byType(InkWell),
        ),
      );
      likeInkWell.onTap?.call();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }
  }

  /// Mở rộng Bottom Sheet bình luận của bài viết đầu tiên
  Future<void> openCommentSection() async {
    final commentButtonFinder = find.byKey(TestKeys.postCommentButton);
    if (commentButtonFinder.evaluate().isNotEmpty) {
      final commentInkWell = tester.widget<InkWell>(
        find.descendant(
          of: commentButtonFinder.first,
          matching: find.byType(InkWell),
        ),
      );
      commentInkWell.onTap?.call();
      await tester.pumpAndSettle();
      await waitForFinder(find.byKey(TestKeys.postCommentTextField));
    }
  }

  /// Nhập văn bản bình luận
  Future<void> writeComment(String commentText) async {
    await enterTextFieldText(TestKeys.postCommentTextField, commentText);
  }

  /// Gửi bình luận đi
  Future<void> submitComment() async {
    final sendButton = find.byKey(TestKeys.postCommentSendButton);
    await tap(sendButton, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
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
      final searchIconButton = tester.widget<IconButton>(searchButtonFinder);
      searchIconButton.onPressed?.call();
      await tester.pumpAndSettle();
    }
  }

  /// Nhấp vào biểu tượng Trò chuyện trên bảng tin
  Future<void> navigateToChat() async {
    final chatButtonFinder = find.byKey(TestKeys.feedChatButton);
    if (chatButtonFinder.evaluate().isNotEmpty) {
      final chatIconButton = tester.widget<IconButton>(chatButtonFinder);
      chatIconButton.onPressed?.call();
      await tester.pumpAndSettle();
    }
  }
}
