import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/src/core/testing/test_keys.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/features/post/presentation/widgets/feed_screen/post_card.dart';
import '../data/mock_data.dart';
import '../core/test_image_picker.dart';
import '../pages/feed/feed_page.dart';
import '../pages/feed/create_post_page.dart';
import '../pages/search/search_page.dart';

/// Chạy luồng tương tác trên Bảng tin: Tạo bài viết, Like, Comment, Tìm kiếm.
///
/// Thứ tự thực hiện quan trọng:
/// 1. Tạo bài viết trước để đảm bảo Feed luôn có data (DB In-Memory ban đầu rỗng).
/// 2. Like và Comment trên chính bài viết vừa tạo.
/// 3. Tìm kiếm người dùng để kiểm tra tính năng Search.
Future<void> runFeedFlow(
  WidgetTester tester,
  FeedPage feedPage,
  SearchPage searchPage,
  CreatePostPage createPostPage,
  String loginUsername,
) async {
  // ── Bước 1: Tạo bài đăng mới ───────────────────────────────────────────────
  // Phải tạo trước vì DB In-Memory mới khởi động sẽ không có bài viết nào.

  // [ASSERTION] Nút tạo bài viết phải tồn tại trên NavBar
  expect(
    find.byKey(TestKeys.navCreate),
    findsOneWidget,
    reason: 'Nút tạo bài viết (navCreate) phải hiển thị trên Bottom NavBar sau khi đăng nhập',
  );

  await createPostPage.navigateToCreatePost();
  await createPostPage.ensureOnPage(TestKeys.createPostCaptionField, AppRoutes.createPost.path);

  // [ASSERTION] Phải đang ở trang Tạo bài viết
  expect(
    find.byKey(TestKeys.createPostCaptionField),
    findsOneWidget,
    reason: 'Trường Caption phải hiển thị trên màn hình Tạo bài viết',
  );

  await createPostPage.fillCaption(MockData.postText);
  await createPostPage.submitPost();

  // [ASSERTION] Sau khi submit, phải tự động quay về màn hình Feed
  await feedPage.ensureOnPage(TestKeys.feedSearchButton, AppRoutes.home.path);
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Phải tự động quay lại Feed sau khi tạo bài viết thành công',
  );

  // Chờ danh sách Feed tải lại và hiển thị bài viết vừa tạo
  await feedPage.waitForKey(TestKeys.postLikeButton);

  // [ASSERTION] Feed phải có ít nhất 1 bài viết (bài vừa tạo)
  expect(
    find.byKey(TestKeys.postLikeButton),
    findsWidgets,
    reason: 'Feed phải có ít nhất 1 bài viết sau khi tạo — kiểm tra API tạo bài viết',
  );

  // ── Bước 2: Like bài viết đầu tiên ────────────────────────────────────────
  await feedPage.likeFirstPost();

  // ── Bước 3: Bình luận bài viết đầu tiên ───────────────────────────────────

  // [ASSERTION] Nút comment phải tồn tại
  expect(
    find.byKey(TestKeys.postCommentButton),
    findsWidgets,
    reason: 'Nút Comment phải hiển thị trên bài viết',
  );

  await feedPage.openCommentSection();

  // [ASSERTION] Section bình luận phải mở ra — trường nhập bình luận phải hiển thị
  expect(
    find.byKey(TestKeys.postCommentTextField),
    findsOneWidget,
    reason: 'Trường nhập bình luận phải hiển thị sau khi mở Comment Section',
  );

  await feedPage.writeComment(MockData.commentText);
  await feedPage.submitComment();
  await feedPage.closeCommentSection();

  // ── Bước 4: Tìm kiếm người dùng ────────────────────────────────────────────
  await feedPage.navigateToSearch();
  await searchPage.ensureOnPage(TestKeys.searchTextField, AppRoutes.homeSearch.path);

  // [ASSERTION] Phải đang ở màn hình Tìm kiếm
  expect(
    find.byKey(TestKeys.searchTextField),
    findsOneWidget,
    reason: 'Trường tìm kiếm phải hiển thị trên màn hình Search',
  );

  await searchPage.searchUser(loginUsername);
  // Chờ kết quả hiển thị thay vì delay cứng 2s
  await searchPage.waitForFinder(find.text(loginUsername));

  // [ASSERTION] Tìm kiếm chính mình phải trả về ít nhất 1 kết quả
  expect(
    find.text(loginUsername).evaluate().isNotEmpty,
    isTrue,
    reason:
        'Tìm kiếm "$loginUsername" phải trả về kết quả — '
        'người dùng vừa đăng ký phải tìm được chính mình',
  );

  await searchPage.goBackToFeed(AppRoutes.home.path);

  // [ASSERTION] Đảm bảo đã quay lại trang Feed thành công
  expect(
    find.byKey(TestKeys.feedSearchButton),
    findsOneWidget,
    reason: 'Phải quay lại màn hình Feed sau khi thoát khỏi Search',
  );
}

/// Chạy riêng luồng tạo bài viết có ảnh để test upload media ở BE.
Future<void> runFeedMediaUploadFlow(
  WidgetTester tester,
  FeedPage feedPage,
  CreatePostPage createPostPage,
) async {
  final imagePostText = MockData.postImageText;
  await TestImagePicker.installGalleryImagePicker(
    fileName: 'e2e_${MockData.flowStamp}_post.png',
  );

  await createPostPage.navigateToCreatePost();
  await createPostPage.ensureOnPage(
    TestKeys.createPostCaptionField,
    AppRoutes.createPost.path,
  );

  expect(
    find.byKey(TestKeys.createPostCaptionField),
    findsOneWidget,
    reason: 'Trường Caption phải hiển thị trên màn hình Tạo bài viết',
  );

  await createPostPage.fillCaption(imagePostText);
  await createPostPage.pickGalleryImage();
  await tester.pumpAndSettle();

  expect(
    find.byKey(TestKeys.createPostLibraryButton),
    findsOneWidget,
    reason: 'Nút chọn ảnh từ thư viện phải hiển thị khi tạo bài viết',
  );

  await createPostPage.submitPost();

  // Chờ bài viết có ảnh xuất hiện trên Feed thay vì delay cứng 3s+5s
  await feedPage.waitForFinder(find.text(imagePostText));

  final postTextFinder = find.text(imagePostText);
  expect(
    postTextFinder,
    findsOneWidget,
    reason: 'Bài viết có ảnh phải xuất hiện lại trên Feed sau khi submit',
  );

  final postCardFinder = find.ancestor(
    of: postTextFinder,
    matching: find.byType(PostCard),
  );
  expect(
    postCardFinder,
    findsOneWidget,
    reason: 'Bài viết vừa tạo phải nằm trong một HomeFeedPostCard riêng',
  );

  final mediaImageFinder = find.descendant(
    of: postCardFinder,
    matching: find.byType(Image),
  );
  expect(
    mediaImageFinder,
    findsWidgets,
    reason: 'Card bài viết có ảnh phải render widget Image trong Feed',
  );
}
