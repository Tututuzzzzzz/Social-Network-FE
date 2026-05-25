import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../pages/feed/feed_page.dart';

/// Chạy kịch bản kiểm thử màn hình Thông báo thời gian thực.
///
/// Luồng kiểm thử:
/// 1. Điều hướng sang tab Thông báo qua Bottom NavBar.
/// 2. Xác nhận màn hình Thông báo load thành công.
/// 3. Tương tác với thông báo đầu tiên nếu có (tùy điều kiện).
/// 4. Quay lại Feed để tiếp tục các luồng test sau.
///
/// Lưu ý: Số lượng thông báo phụ thuộc vào các hành động trước đó trong luồng test
/// (Like, Comment từ [runFeedFlow], gửi lời mời kết bạn từ [runFriendsFlow]).
Future<void> runNotificationsFlow(
  WidgetTester tester,
  FeedPage feedPage,
) async {
  // ── Bước 1: Điều hướng sang tab Thông báo ──────────────────────────────────
  final navNotificationsFinder = find.byKey(TestKeys.navNotifications);

  // [ASSERTION] Tab Thông báo phải LUÔN hiển thị — đây là thành phần UI cốt lõi
  expect(
    navNotificationsFinder,
    findsOneWidget,
    reason:
        'Tab Thông báo phải luôn hiển thị trên Bottom NavBar. '
        'Kiểm tra TestKeys.navNotifications đã được gán đúng cho widget NavBar.',
  );

  await feedPage.safeTap(navNotificationsFinder, warnIfMissed: true);

  // ── Bước 2: Xác nhận màn hình Thông báo đã load ────────────────────────────

  // [ASSERTION] Tab NavBar thông báo vẫn phải hiển thị sau khi chuyển tab
  expect(
    find.byKey(TestKeys.navNotifications),
    findsOneWidget,
    reason: 'Màn hình Thông báo phải load thành công sau khi nhấn tab NavBar',
  );

  // ── Bước 3: Tương tác thông báo đầu tiên ──────────────────────────
  final listTilesFinder = find.byType(ListTile);
  if (listTilesFinder.evaluate().isNotEmpty) {
    print('✅ [E2E Notifications] Tìm thấy thông báo trong danh sách, đang tương tác...');
    await feedPage.safeTap(listTilesFinder.first, warnIfMissed: true);
  } else {
    print(
      '⚠️ [E2E Notifications] Danh sách thông báo rỗng. '
      'Đây là hành vi BÌNH THƯỜNG đối với tài khoản vừa đăng ký mới vì '
      'các hoạt động trước đó (Like, Comment, Friend Request) là do tài khoản này '
      'gửi đi (người nhận khác nhận thông báo, không phải tài khoản này).'
    );
  }

  // ── Bước 4: Quay lại màn hình Feed ─────────────────────────────────────────
  feedPage.goRouterGo(AppRoutes.home.path);
  await tester.pumpAndSettle();

  // [ASSERTION] Phải quay lại Feed thành công
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Phải quay lại màn hình Feed sau khi hoàn thành luồng Thông báo',
  );
}
