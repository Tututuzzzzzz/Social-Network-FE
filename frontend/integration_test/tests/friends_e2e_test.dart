import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../pages/feed/feed_page.dart';
import '../pages/search/search_page.dart';

Future<void> runFriendsFlow(
  WidgetTester tester,
  FeedPage feedPage,
  SearchPage searchPage, {
  required String targetUsername,
}) async {
  await feedPage.navigateToSearch();
  await searchPage.ensureOnPage(
    TestKeys.searchTextField,
    AppRoutes.homeSearch.path,
  );

  expect(
    find.byKey(TestKeys.searchTextField),
    findsOneWidget,
    reason: 'Search screen must load from Feed.',
  );

  await searchPage.searchUser(targetUsername);
  // Chờ kết quả tìm kiếm xuất hiện thay vì delay cứng 3s
  await searchPage.waitForFinder(find.text('@$targetUsername'));

  final userResultsFinder = find.text('@$targetUsername');
  expect(
    userResultsFinder.evaluate().isNotEmpty,
    isTrue,
    reason: 'Seeded target user @$targetUsername must appear in search.',
  );

  await searchPage.tap(userResultsFinder.first);
  // Chờ trang profile load xong (icon add-friend hoặc check xuất hiện) thay vì delay cứng 3s
  await searchPage.waitForFinder(
    find.byIcon(Icons.person_add_alt_1_rounded).evaluate().isNotEmpty
        ? find.byIcon(Icons.person_add_alt_1_rounded)
        : find.byIcon(Icons.check_rounded),
  );

  final addFriendIcon = find.byIcon(Icons.person_add_alt_1_rounded);
  final checkIcon = find.byIcon(Icons.check_rounded);

  expect(
    addFriendIcon.evaluate().isNotEmpty || checkIcon.evaluate().isNotEmpty,
    isTrue,
    reason: 'Target profile must show add-friend or sent/friend state.',
  );

  if (addFriendIcon.evaluate().isNotEmpty) {
    await searchPage.tap(addFriendIcon);
    // Chờ nút chuyển sang trạng thái "đã gửi" thay vì delay cứng 3s
    await searchPage.waitForFinder(find.byIcon(Icons.check_rounded));

    expect(
      find.byIcon(Icons.check_rounded).evaluate().isNotEmpty,
      isTrue,
      reason: 'After sending a friend request, the button must switch state.',
    );
  }

  final backIconFinder = find.byIcon(Icons.arrow_back);
  if (backIconFinder.evaluate().isNotEmpty) {
    await searchPage.tap(backIconFinder.first);
    // Chờ quay lại trang Search (text field còn hiển thị) thay vì delay cứng 2s
    await searchPage.waitForKey(TestKeys.searchTextField);
  }

  await searchPage.goBackToFeed(AppRoutes.home.path);

  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Must return to Feed after friend flow.',
  );
}
