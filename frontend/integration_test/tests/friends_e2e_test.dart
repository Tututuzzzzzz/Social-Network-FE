import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/feed/feed_page.dart';
import '../pages/search/search_page.dart';

/// Chạy kịch bản kiểm thử tìm kiếm và tương tác kết bạn.
///
/// Tài khoản mục tiêu: [MockData.seedAdminUsername] (`admin`) — luôn được seed
/// sẵn bởi `run-e2e-server.ts` → `seed.ts` khi E2E backend khởi động.
///
/// Logic nút kết bạn trong ứng dụng (ProfileActionBar):
/// - Chưa gửi lời mời  → icon `person_add_alt_1_rounded` (có thể nhấn)
/// - Đã gửi / Đã là bạn → icon `check_rounded` (không thể nhấn lại)
///
/// Test này kiểm tra LUỒNG KẾT BẠN, không cứng nhắc vào trạng thái ban đầu,
/// vì trạng thái phụ thuộc vào dữ liệu In-Memory DB hiện tại.
Future<void> runFriendsFlow(
  WidgetTester tester,
  FeedPage feedPage,
  SearchPage searchPage,
) async {
  // ── Bước 1: Điều hướng tới màn hình Tìm kiếm ───────────────────────────────
  await feedPage.navigateToSearch();
  await searchPage.ensureOnPage(TestKeys.searchTextField, AppRoutes.homeSearch.path);

  // [ASSERTION] Phải đang ở màn hình Tìm kiếm
  expect(
    find.byKey(TestKeys.searchTextField),
    findsOneWidget,
    reason: 'Màn hình Tìm kiếm phải load được từ Feed',
  );

  // ── Bước 2: Tìm kiếm tài khoản seed (admin) ────────────────────────────────
  await searchPage.searchUser(MockData.seedAdminUsername);
  await searchPage.waitForFinder(
    find.text('@${MockData.seedAdminUsername}'),
    timeout: const Duration(seconds: 10),
  );

  // [ASSERTION] Tài khoản seed PHẢI xuất hiện trong kết quả
  // Tìm kiếm bằng "@admin" (được hiển thị trong SearchResultCard) để tránh khớp
  // nhầm với từ khóa "admin" đang được hiển thị trong ô nhập liệu (searchTextField).
  final userResultsFinder = find.text('@${MockData.seedAdminUsername}');
  expect(
    userResultsFinder.evaluate().isNotEmpty,
    isTrue,
    reason:
        'Tài khoản "@${MockData.seedAdminUsername}" phải tồn tại trong kết quả tìm kiếm. '
        'Kiểm tra run-e2e-server.ts đã seed tài khoản này vào In-Memory DB.',
  );

  // ── Bước 3: Mở trang cá nhân của người dùng tìm được ──────────────────────
  await searchPage.safeTap(userResultsFinder.first, warnIfMissed: true);

  // ── Bước 4: Kiểm tra và tương tác với nút kết bạn ──────────────────────────
  // ProfileActionBar hiển thị 2 trạng thái:
  //   a) person_add_alt_1_rounded → chưa gửi lời mời (có thể nhấn)
  //   b) check_rounded            → đã gửi lời mời hoặc đã là bạn (không thể nhấn lại)
  // Cả hai đều là trạng thái HỢP LỆ — test kiểm tra đúng hành vi của từng trạng thái.

  final addFriendIcon = find.byIcon(Icons.person_add_alt_1_rounded);
  final checkIcon = find.byIcon(Icons.check_rounded);

  // Chờ cho đến khi hiển thị một trong hai icon
  final hasActionBar = await searchPage.tryWaitForFinder(
    addFriendIcon,
    timeout: const Duration(seconds: 5),
  ) || await searchPage.tryWaitForFinder(
    checkIcon,
    timeout: const Duration(seconds: 1),
  );

  // [ASSERTION] Màn hình profile phải luôn hiển thị MỘT trong hai trạng thái nút
  // Nếu cả hai đều không tìm thấy → UI không render đúng ProfileActionBar
  expect(
    addFriendIcon.evaluate().isNotEmpty || checkIcon.evaluate().isNotEmpty,
    isTrue,
    reason:
        'Trang cá nhân của "${MockData.seedAdminUsername}" phải hiển thị nút kết bạn '
        '(person_add_alt_1_rounded) HOẶC nút đã gửi (check_rounded). '
        'Kiểm tra ProfileActionBar được render đúng trên màn hình.',
  );

  if (addFriendIcon.evaluate().isNotEmpty) {
    // Trạng thái a: Chưa gửi lời mời → gửi và kiểm tra nút chuyển trạng thái
    await searchPage.safeTap(addFriendIcon, warnIfMissed: true);
    await searchPage.waitForFinder(
      find.byIcon(Icons.check_rounded),
      timeout: const Duration(seconds: 5),
    );

    // [ASSERTION] Sau khi gửi, nút PHẢI chuyển sang check_rounded
    expect(
      find.byIcon(Icons.check_rounded).evaluate().isNotEmpty,
      isTrue,
      reason:
          'Sau khi gửi lời mời kết bạn, nút phải chuyển sang trạng thái "Đã gửi" '
          '(icon check_rounded). Kiểm tra API /api/friends/requests của backend.',
    );
  }
  // Trạng thái b: Đã gửi / đã là bạn → không cần làm gì, chỉ tiếp tục

  // ── Bước 5: Quay lại màn hình Tìm kiếm ────────────────────────────────────
  final backIconFinder = find.byIcon(Icons.arrow_back);
  if (backIconFinder.evaluate().isNotEmpty) {
    await searchPage.safeTap(backIconFinder.first, warnIfMissed: true);
  }

  // ── Bước 6: Quay lại Feed chính ────────────────────────────────────────────
  await searchPage.goBackToFeed(AppRoutes.home.path);

  // [ASSERTION] Phải quay lại được màn hình Feed
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Phải quay lại màn hình Feed sau khi hoàn thành luồng Kết bạn',
  );
}
