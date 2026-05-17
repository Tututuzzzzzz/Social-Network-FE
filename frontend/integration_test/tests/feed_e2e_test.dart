import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import '../data/mock_data.dart';
import '../pages/feed/feed_page.dart';
import '../pages/feed/create_post_page.dart';
import '../pages/search/search_page.dart';

/// Chạy luồng tương tác trên Bảng tin, Thích, Bình luận, Tìm kiếm và Tạo bài viết mới
Future<void> runFeedFlow(
  WidgetTester tester,
  FeedPage feedPage,
  SearchPage searchPage,
  CreatePostPage createPostPage,
  String loginUsername,
) async {
  // 1. Luồng Tương tác: Thích (Like) bài viết
  await feedPage.likeFirstPost();

  // 2. Luồng Tương tác: Bình luận (Comment) bài viết
  await feedPage.openCommentSection();
  await feedPage.writeComment(MockData.commentText);
  await feedPage.submitComment();
  await feedPage.closeCommentSection();

  // 3. Luồng Tìm kiếm người dùng (Search)
  await feedPage.navigateToSearch();
  await searchPage.ensureOnPage(TestKeys.searchTextField, AppRoutes.homeSearch.path);
  await searchPage.searchUser(loginUsername);
  await searchPage.goBackToFeed(AppRoutes.home.path);

  // [ASSERTION] Đảm bảo đã quay lại trang Feed thành công
  expect(find.byKey(TestKeys.feedSearchButton), findsOneWidget);

  // 4. Luồng Tạo bài đăng mới (Create Post)
  await createPostPage.navigateToCreatePost();
  await createPostPage.ensureOnPage(TestKeys.createPostCaptionField, AppRoutes.createPost.path);
  await createPostPage.fillCaption(MockData.postText);
  await createPostPage.submitPost();

  // [ASSERTION] Đảm bảo đã tự động quay lại trang Feed chính sau khi tạo bài viết
  await feedPage.ensureOnPage(TestKeys.feedSearchButton, AppRoutes.home.path);
  expect(find.byKey(TestKeys.feedSearchButton), findsOneWidget);
}
