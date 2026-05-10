// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get welcomeTaglineConnect => 'Kết nối mọi người';

  @override
  String get welcomeTaglineRelationship => 'Mở ra các mối quan hệ mới';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get loginUsernameHint => 'Nhập tên đăng nhập';

  @override
  String get loginPasswordHint => 'Nhập mật khẩu';

  @override
  String get rememberPassword => 'Nhớ mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get orText => 'hoặc';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String get noAccountQuestion => 'Chưa có tài khoản?';

  @override
  String get haveAccountQuestion => 'Tôi đã có tài khoản rồi.';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordDescription =>
      'Nhập email liên kết với tài khoản để nhận mật khẩu mới được gửi trực tiếp qua hòm thư của bạn';

  @override
  String get enterEmailHint => 'Nhập email';

  @override
  String get sendVerificationCode => 'Gửi mật khẩu mới';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập email';

  @override
  String get otpEnterCodeTitle => 'Nhập mã xác nhận';

  @override
  String otpDescription(Object maskedEmail) {
    return 'Để xác nhận tài khoản, hãy nhập mã gồm 6 chữ số mà chúng tôi đã gửi đến địa chỉ $maskedEmail.';
  }

  @override
  String get otpCodeHint => 'Nhập mã xác nhận';

  @override
  String get next => 'Tiếp';

  @override
  String get pleaseEnterSixDigitCode => 'Vui lòng nhập mã 6 chữ số';

  @override
  String get resendCode => 'Gửi lại mã';

  @override
  String get didNotReceiveCode => 'Tôi không nhận được mã';

  @override
  String get alreadyHaveAccount => 'Tôi có tài khoản rồi';

  @override
  String get createNewPasswordTitle => 'Tạo mật khẩu mới';

  @override
  String get createNewPasswordDescription =>
      'Tạo mật khẩu gồm ít nhất 6 chữ cái hoặc chữ số. Bạn nên chọn mật khẩu thật khó đoán.';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get invalidOrMismatchedPassword =>
      'Mật khẩu không hợp lệ hoặc không trùng khớp';

  @override
  String get firstNameHint => 'Tên';

  @override
  String get lastNameHint => 'Họ';

  @override
  String get usernameHint => 'Tên người dùng';

  @override
  String get reenterPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get pleaseEnterFullName => 'Vui lòng nhập họ và tên';

  @override
  String get pleaseEnterUsername => 'Vui lòng nhập tên người dùng';

  @override
  String get pleaseEnterValidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get passwordTooShortOrMismatch => 'Mật khẩu quá ngắn hoặc không khớp';

  @override
  String get registerSuccess => 'Đăng ký thành công';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get done => 'Xong';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get confirmAction => 'Xác nhận';

  @override
  String get profileChooseAccount => 'Chọn tài khoản';

  @override
  String get profileAccountSwitched => 'Đã chuyển tài khoản.';

  @override
  String get addAccount => 'Thêm tài khoản';

  @override
  String get addAccountSoon => 'Tính năng thêm tài khoản sẽ sớm được ra mắt.';

  @override
  String get settingsAndActivity => 'Cài đặt và hoạt động';

  @override
  String get profileSettingsTitle => 'Cài Đặt';

  @override
  String get logoutAction => 'Đăng xuất';

  @override
  String get logoutFailed => 'Đăng xuất thất bại';

  @override
  String get archive => 'Kho lưu trữ';

  @override
  String get switchToProfessionalAccount =>
      'Chuyển sang tài khoản chuyên nghiệp';

  @override
  String get switchToBusinessAccount => 'Chuyển sang tài khoản công ty';

  @override
  String get switchAccount => 'Chuyển tài khoản';

  @override
  String get featureInDevelopment => 'Tính năng đang được phát triển';

  @override
  String get loadingProfileInfo => 'Đang tải thông tin...';

  @override
  String get noProfileData => 'Chưa có dữ liệu hồ sơ.';

  @override
  String get postsLabel => 'Bài viết';

  @override
  String get followersLabel => 'người theo dõi';

  @override
  String get followingLabel => 'đang theo dõi';

  @override
  String get editAction => 'Chỉnh sửa';

  @override
  String get shareProfileAction => 'Chia sẻ trang cá nhân';

  @override
  String get newLabel => 'Mới';

  @override
  String get taggedPostsEmpty => 'Chưa có bài viết được gắn thẻ.';

  @override
  String get linkCopied => 'Đã sao chép liên kết';

  @override
  String get pageNotImplemented => 'Trang này chưa được triển khai.';

  @override
  String get editProfileTitle => 'Chỉnh sửa trang cá nhân';

  @override
  String get displayNameLabel => 'Tên hiển thị';

  @override
  String get editAvatarAction => 'Chỉnh sửa ảnh hoặc avatar';

  @override
  String get pleaseEnterDisplayName => 'Vui lòng nhập tên hiển thị';

  @override
  String get profileUpdateSuccess => 'Đã cập nhật trang cá nhân thành công.';

  @override
  String get profileUpdateFailed => 'Không thể cập nhật trang cá nhân.';

  @override
  String get profileNoChanges => 'Chưa có thay đổi nào để cập nhật.';

  @override
  String get profileLoadFailed => 'Không thể tải trang cá nhân.';

  @override
  String get retryAction => 'Thử lại';

  @override
  String get updateAvatarSuccess => 'Đã cập nhật ảnh đại diện thành công.';

  @override
  String get updateAvatarFailed => 'Không thể cập nhật ảnh đại diện.';

  @override
  String get profileSavedLocal =>
      'Đã lưu thông tin trang cá nhân vào bộ nhớ tạm.';

  @override
  String get privateAccount => 'Tài khoản riêng tư';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Điện thoại';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get profileFormSampleData => 'Dữ liệu đang sử dụng mẫu thử nghiệm.';

  @override
  String get mediaLibrary => 'Thư viện';

  @override
  String get mediaSelectedReady => 'Đã chọn ảnh, sẵn sàng tiếp tục.';

  @override
  String get chatGroupInfoTitle => 'Thông tin nhóm';

  @override
  String get groupNotFound => 'Không tìm thấy thông tin nhóm';

  @override
  String membersCount(Object count) {
    return '$count thành viên';
  }

  @override
  String get groupRename => 'Đổi tên nhóm';

  @override
  String get groupChangeAvatar => 'Đổi ảnh nhóm';

  @override
  String get addMember => 'Thêm thành viên';

  @override
  String get searchMessages => 'Tìm tin nhắn';

  @override
  String get photosAndVideos => 'Ảnh và video';

  @override
  String get adminOnlyManageGroupInfo =>
      'Chỉ quản trị viên mới có quyền thay đổi thông tin và thêm thành viên.';

  @override
  String get memberList => 'Danh sách thành viên';

  @override
  String get youSuffix => 'bạn';

  @override
  String get adminRole => 'Quản trị viên';

  @override
  String get memberRole => 'Thành viên';

  @override
  String get searchHint => 'Tìm kiếm người dùng, bài viết, địa điểm';

  @override
  String get searchLabel => 'Tìm kiếm';

  @override
  String get searchPeople => 'Mọi người';

  @override
  String get searchPosts => 'Bài viết';

  @override
  String get searchPhotos => 'Ảnh';

  @override
  String get searchPlaces => 'Địa điểm';

  @override
  String get searchNoResults => 'Không tìm thấy kết quả';

  @override
  String get searchSeeAll => 'Xem tất cả';

  @override
  String get leaveGroup => 'Rời nhóm';

  @override
  String get lastAdminCannotLeave =>
      'Bạn là quản trị viên cuối cùng. Hãy chuyển quyền quản trị trước khi rời nhóm.';

  @override
  String get groupChatFallback => 'Nhóm chat';

  @override
  String get groupMemberAdded => 'Đã thêm thành viên vào nhóm';

  @override
  String get leaveGroupQuestion => 'Rời nhóm?';

  @override
  String get leaveGroupNoNewMessages =>
      'Bạn sẽ không nhận được tin nhắn mới từ nhóm này nữa.';

  @override
  String get selectNewAdminBeforeLeave =>
      'Bạn là quản trị viên cuối cùng. Hãy chọn quản trị viên mới trước khi rời nhóm.';

  @override
  String get noMemberToTransfer =>
      'Hiện không có thành viên nào để chuyển quyền.';

  @override
  String get currentRoleAdmin => 'Vai trò hiện tại: Quản trị viên';

  @override
  String get currentRoleMember => 'Vai trò hiện tại: Thành viên';

  @override
  String get cannotLeaveGroupCheckAdmin =>
      'Không thể rời nhóm. Vui lòng kiểm tra lại quyền quản trị.';

  @override
  String get leftGroupSuccess => 'Bạn đã rời nhóm thành công.';

  @override
  String get handoverAndLeaveSuccess =>
      'Đã chuyển quyền quản trị và rời nhóm thành công.';

  @override
  String get secondConfirmation => 'Xác nhận lần nữa';

  @override
  String get aboutToHandoverAndLeave =>
      'Bạn sắp chuyển quyền quản trị viên và rời nhóm.';

  @override
  String get newAdminWillBe => 'Sẽ trở thành quản trị viên mới';

  @override
  String get afterConfirmLeaveImmediately =>
      'Sau khi xác nhận, bạn sẽ rời nhóm ngay lập tức.';

  @override
  String get goBack => 'Quay lại';

  @override
  String get confirmHandover => 'Xác nhận chuyển quyền';

  @override
  String get adminOnlyAction =>
      'Chỉ quản trị viên mới có quyền thực hiện thao tác này.';

  @override
  String get chatInviteLink => 'Liên kết mời';

  @override
  String get inviteLinkCopied => 'Đã sao chép liên kết mời nhóm.';

  @override
  String get addPeople => 'Thêm người';

  @override
  String youBlockedUser(Object name) {
    return 'Bạn đã chặn $name';
  }

  @override
  String youRestrictedUser(Object name) {
    return 'Bạn đã hạn chế $name';
  }

  @override
  String get noOnlineOrReadStatus =>
      'Họ sẽ không thấy trạng thái hoạt động hoặc đã đọc của bạn.';

  @override
  String get blockAction => 'Chặn';

  @override
  String get unblockAction => 'Bỏ chặn';

  @override
  String get unrestrictAction => 'Bỏ hạn chế';

  @override
  String get onlyAdminCanAddMembers =>
      'Chỉ quản trị viên mới có thể thêm thành viên.';

  @override
  String get messagesSearchHint => 'Tìm kiếm';

  @override
  String get messagesTitle => 'Tin nhắn';

  @override
  String get pendingMessages => 'Tin nhắn đang chờ';

  @override
  String get noConversationFound => 'Không tìm thấy cuộc trò chuyện nào.';

  @override
  String get chatPinned => 'Đã ghim đoạn chat.';

  @override
  String get chatUnpinned => 'Đã bỏ ghim đoạn chat.';

  @override
  String get chatHidden => 'Đã ẩn đoạn chat.';

  @override
  String get chatDeleted => 'Đã xóa đoạn chat.';

  @override
  String get pinAction => 'Ghim';

  @override
  String get unpinAction => 'Bỏ ghim';

  @override
  String get hideAction => 'Ẩn';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get mutedNow => 'Đang tắt thông báo';

  @override
  String get feedNotificationSoon => 'Thông báo sẽ sớm được cập nhật.';

  @override
  String get sessionExpiredRelogin =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get emptyNoPosts => 'Chưa có bài viết nào.';

  @override
  String get emptyFollowFriends =>
      'Hãy quay lại sau hoặc theo dõi thêm bạn bè.';

  @override
  String get shareSoon => 'Tính năng chia sẻ sẽ sớm được cập nhật.';

  @override
  String get saveSoon => 'Tính năng lưu bài viết sẽ sớm được cập nhật.';

  @override
  String get createPostCannotPickGallery => 'Không thể chọn ảnh từ thư viện.';

  @override
  String get createPostCannotOpenCamera => 'Không thể mở máy ảnh.';

  @override
  String get createPostTitle => 'Tạo bài viết';

  @override
  String get postAction => 'Đăng';

  @override
  String get captionHint => 'Bạn đang nghĩ gì?';

  @override
  String get addMediaForPost => 'Thêm ảnh/video cho bài viết';

  @override
  String get pickFromLibrary => 'Chọn từ thư viện';

  @override
  String get libraryLabel => 'Hình ảnh';

  @override
  String get cameraLabel => 'Máy ảnh';

  @override
  String get templateLabel => 'Mẫu bài viết';

  @override
  String get templateSoon => 'Các mẫu bài viết sẽ sớm được cập nhật.';

  @override
  String get friendsSearchHint => 'Tìm kiếm bạn bè';

  @override
  String cannotOpenChat(Object error) {
    return 'Không thể mở cuộc trò chuyện: $error';
  }

  @override
  String get placeholderLastMessage => 'Đây là nội dung tin nhắn mẫu.';

  @override
  String get messageInputHint => 'Nhắn tin...';

  @override
  String get bioLabel => 'Tiểu sử';

  @override
  String get myLoveLabel => 'Tình yêu của tôi';

  @override
  String get searchInConversationHint => 'Tìm trong cuộc trò chuyện';

  @override
  String get enterKeywordToSearch => 'Nhập từ khóa để tìm tin nhắn';

  @override
  String get noMatchingResults => 'Không tìm thấy kết quả phù hợp.';

  @override
  String get youLabel => 'Bạn';

  @override
  String get enterNicknameHint => 'Nhập biệt danh';

  @override
  String nicknameRemoved(Object name) {
    return 'Đã xóa biệt danh của $name';
  }

  @override
  String nicknameUpdated(Object name) {
    return 'Đã cập nhật biệt danh của $name';
  }

  @override
  String nicknameVisibleInChat(Object name) {
    return 'Mọi người trong đoạn chat đều sẽ nhìn thấy biệt danh này của $name.';
  }

  @override
  String get groupNameHint => 'Tên nhóm';

  @override
  String get invitedMembers => 'Thành viên được mời';

  @override
  String get searchGeneric => 'Tìm kiếm';

  @override
  String get safetyProfile => 'Trang cá nhân';

  @override
  String get restrictAction => 'Hạn chế';

  @override
  String get blockAccount => 'Chặn tài khoản';

  @override
  String get unblockAccount => 'Bỏ chặn tài khoản';

  @override
  String get nicknameAction => 'Biệt danh';

  @override
  String get createGroupChat => 'Tạo nhóm chat';

  @override
  String get optionsLabel => 'Lựa chọn';

  @override
  String get muteOffLabel => 'Tắt';

  @override
  String get photosAndVideoTitle => 'Ảnh và Video';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get blockedMediaHidden =>
      'Nội dung ảnh và video bị ẩn do bạn đã chặn tài khoản này.';

  @override
  String get mute10Minutes => '10 phút';

  @override
  String get mute30Minutes => '30 phút';

  @override
  String get mute1Hour => '1 giờ';

  @override
  String get mute2Hours => '2 giờ';

  @override
  String get mute12Hours => '12 giờ';

  @override
  String get mute24Hours => '24 giờ';

  @override
  String get mute48Hours => '48 giờ';

  @override
  String get muteConversationTitle => 'Tắt thông báo đoạn chat';

  @override
  String get turnOnNotifications => 'Bật thông báo';

  @override
  String get grantAdmin => 'Cấp quyền quản trị viên';

  @override
  String get revokeAdmin => 'Gỡ quyền quản trị viên';

  @override
  String get revokeAdminLocked => 'Gỡ quyền quản trị viên (bị khóa)';

  @override
  String get onlyAdminCanChangeRole => 'Chỉ quản trị viên mới được đổi vai trò';

  @override
  String get privateMessage => 'Nhắn tin riêng';

  @override
  String get thisIsYourAccount => 'Đây là tài khoản của bạn';

  @override
  String get newGroupTitle => 'Nhóm mới';

  @override
  String get editGroupTitle => 'Chỉnh sửa nhóm';

  @override
  String get createAction => 'Tạo';

  @override
  String get peopleWhoCanContactYou => 'Người có thể liên hệ với bạn';

  @override
  String get editNicknameTitle => 'Chỉnh sửa biệt danh';

  @override
  String get groupRoleTitle => 'Vai trò trong nhóm';

  @override
  String get memberIdTitle => 'ID thành viên';

  @override
  String adminGrantedTo(Object name) {
    return 'Đã cấp quyền quản trị cho $name';
  }

  @override
  String get cannotGrantAdmin => 'Không thể cấp quyền quản trị';

  @override
  String adminRevokedFrom(Object name) {
    return 'Đã gỡ quyền quản trị của $name';
  }

  @override
  String get cannotRevokeAdmin => 'Không thể gỡ quyền quản trị';

  @override
  String get cannotRevokeOwnAdminTooltip =>
      'Bạn không thể tự gỡ quyền quản trị của chính mình. Hãy cấp quyền cho người khác trước.';

  @override
  String get cannotRevokeOwnAdmin => 'Bạn không thể tự gỡ quyền quản trị viên';

  @override
  String get onlyAdminCanGrantOrRevokeTooltip =>
      'Chỉ quản trị viên mới có thể cấp hoặc gỡ vai trò quản trị.';

  @override
  String get noAdminPermissionForAction =>
      'Bạn không có quyền quản trị để thực hiện thao tác này';

  @override
  String get cannotRevokeLastAdmin =>
      'Không thể gỡ quyền quản trị cuối cùng trong nhóm.';

  @override
  String get youAreCurrentAdmin => 'Bạn là quản trị viên hiện tại';

  @override
  String get adminHasFullControl => 'Quản trị viên có toàn quyền';

  @override
  String get canGrantOrRevokeForOthers =>
      'Bạn có thể cấp/gỡ quyền quản trị cho thành viên khác.';

  @override
  String get youHaveAdminRights => 'Bạn có quyền quản trị';

  @override
  String get canChangeMemberRoles =>
      'Bạn có thể thay đổi vai trò thành viên trong nhóm.';

  @override
  String get noPermissionChangeRole => 'Bạn không có quyền đổi vai trò';

  @override
  String get onlyAdminCanGrantOrRevoke =>
      'Chỉ quản trị viên mới được phép cấp/gỡ quyền quản trị.';

  @override
  String get mutePriorityHint =>
      'Ưu tiên cao nhất: Hủy toàn bộ trạng thái tắt thông báo hiện tại.';

  @override
  String get muteUntilTurnedOn => 'Cho đến khi được bật lại';

  @override
  String get exploreTitle => 'Khám phá';

  @override
  String get reelsTitle => 'Reels';

  @override
  String get postOptionAddToFavorites => 'Thêm vào mục yêu thích';

  @override
  String get postOptionAboutThisAccount => 'Giới thiệu về tài khoản này';

  @override
  String get postOptionHidePost => 'Ẩn bài viết';

  @override
  String get postOptionReport => 'Báo cáo';

  @override
  String get postOptionAddToFavoritesDone => 'Đã thêm vào mục yêu thích';

  @override
  String get postOptionHidePostDone => 'Đã ẩn bài viết';

  @override
  String get postOptionReportDone => 'Đã gửi báo cáo thành công';

  @override
  String postOptionReportDoneWithReason(Object reason) {
    return 'Đã gửi báo cáo với lý do: $reason';
  }

  @override
  String get postReportTitle => 'Báo cáo bài viết';

  @override
  String get postReportSelectReason => 'Chọn lý do phù hợp nhất';

  @override
  String get postReportSubmit => 'Gửi báo cáo';

  @override
  String get postReportReasonSpam => 'Nội dung rác (Spam)';

  @override
  String get postReportReasonHarassment => 'Quấy rối hoặc bắt nạt';

  @override
  String get postReportReasonFalseInfo => 'Thông tin sai lệch';

  @override
  String get postReportReasonHateSpeech => 'Ngôn từ thù ghét';

  @override
  String get postReportReasonViolence => 'Bạo lực hoặc nội dung nguy hiểm';

  @override
  String get postReportReasonOther => 'Lý do khác';

  @override
  String get postOptionAllHiddenTitle => 'Bạn đã ẩn tất cả bài viết';

  @override
  String get postOptionAllHiddenDescription =>
      'Hãy tải lại để xem nội dung mới hoặc chờ bài viết khác.';

  @override
  String get followingStatus => 'Đang theo dõi';

  @override
  String get yourStory => 'Tin của bạn';

  @override
  String viewAllComments(Object count) {
    return 'Xem tất cả $count bình luận';
  }

  @override
  String likesCountText(Object count) {
    return '$count lượt thích';
  }

  @override
  String get followAction => 'Theo dõi';

  @override
  String get recentSearchTitle => 'Tìm kiếm gần đây';

  @override
  String get friendRequestSent => 'Đã gửi lời mời';

  @override
  String get friendRequestSendSuccess => 'Đã gửi lời mời kết bạn';

  @override
  String get friendRequestSendError => 'Gửi lời mời kết bạn thất bại';

  @override
  String get acceptFriendRequest => 'Chấp nhận';

  @override
  String get rejectFriendRequest => 'Từ chối';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get markAllAsRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get titleSearch => 'Tìm kiếm';

  @override
  String get titleReels => 'Reels';

  @override
  String get titleChat => 'Trò chuyện';

  @override
  String get friends => 'Bạn bè';

  @override
  String get friendRequestAccepted => 'Lời mời kết bạn đã được chấp nhận';

  @override
  String get yourFriendRequestAccepted =>
      'Lời mời kết bạn của bạn đã được chấp nhận';

  @override
  String get friendRequestReceived => 'đã gửi lời mời kết bạn cho bạn';

  @override
  String get noNotifications => 'Chưa có thông báo nào';

  @override
  String get onboardingWelcomeTitle => 'Chào mừng đến với Mochi';

  @override
  String get onboardingWelcomeDesc =>
      'Mạng xã hội kết nối mọi người, sẻ chia khoảnh khắc ý nghĩa trong cuộc sống của bạn.';

  @override
  String get onboardingConnectTitle => 'Kết nối bạn bè';

  @override
  String get onboardingConnectDesc =>
      'Tìm kiếm và kết nối với bạn bè ở khắp mọi nơi. Cùng nhau tạo nên những kỷ niệm đẹp.';

  @override
  String get onboardingShareTitle => 'Chia sẻ đam mê';

  @override
  String get onboardingShareDesc =>
      'Đăng tải những bài viết, hình ảnh và video về những điều bạn yêu thích mỗi ngày.';

  @override
  String get onboardingChatTitle => 'Trò chuyện không giới hạn';

  @override
  String get onboardingChatDesc =>
      'Nhắn tin, gọi điện miễn phí với chất lượng cao. Giữ liên lạc với những người thân yêu.';

  @override
  String get onboardingStart => 'Bắt đầu ngay';

  @override
  String get onboardingNext => 'Tiếp theo';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get notificationTabPosts => 'Bài viết';

  @override
  String get notificationTabFriends => 'Kết bạn';

  @override
  String get notificationEmptyPosts => 'Chưa có thông báo bài viết nào';

  @override
  String get notificationEmptyFriends => 'Chưa có lời mời kết bạn nào';

  @override
  String get notificationLiked => 'đã thích bài viết của bạn';

  @override
  String get notificationCommented => 'đã bình luận về bài viết của bạn';

  @override
  String get notificationFollowed => 'đã bắt đầu theo dõi bạn';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navCreate => 'Bài viết';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get userDefaultName => 'Người dùng';

  @override
  String get profilePersonalTitle => 'Hồ Sơ Cá Nhân';

  @override
  String get noSessionTitle => 'Chưa có phiên đăng nhập';

  @override
  String get noSessionMessage => 'Vui lòng đăng nhập lại để xem hồ sơ cá nhân.';

  @override
  String get retry => 'Thử lại';

  @override
  String get noBio => 'Chưa có giới thiệu.';

  @override
  String get friendsLabel => 'Bạn bè';

  @override
  String get photosLabel => 'Ảnh';

  @override
  String get unknownRecipient => 'Không xác định được người nhận tin nhắn';

  @override
  String get unknownSenderLabel => 'Không xác định';

  @override
  String get deletedMessageLabel => 'Tin nhắn đã xóa';

  @override
  String get todayLabel => 'Hôm nay';

  @override
  String get attachmentLabel => 'Tệp đính kèm';

  @override
  String get messagePickMediaFailed => 'Không thể chọn hoặc chụp media.';

  @override
  String get startChatting => 'Bắt đầu trò chuyện...';

  @override
  String get timeNow => 'vừa xong';

  @override
  String get conversationTitle => 'Cuộc trò chuyện';

  @override
  String get searchCategoryTrending => 'Xu hướng';

  @override
  String get searchCategoryTravel => 'Du lịch';

  @override
  String get searchCategoryFood => 'Ẩm thực';

  @override
  String get searchCategoryMusic => 'Âm nhạc';

  @override
  String get searchCategoryLandscape => 'Phong cảnh';

  @override
  String get searchCategoryTech => 'Công nghệ';

  @override
  String get noResultsFound => 'Không tìm thấy kết quả';

  @override
  String get peopleLabel => 'Mọi người';

  @override
  String get discoverLabel => 'Khám phá';

  @override
  String get exploreLabel => 'Tìm hiểu';

  @override
  String get deleteChatTitle => 'Xóa đoạn chat';

  @override
  String deleteChatConfirm(Object name) {
    return 'Bạn có muốn xóa đoạn chat với $name không?';
  }

  @override
  String get delete => 'Xóa';

  @override
  String get loadMessagesFailed => 'Không thể tải tin nhắn';

  @override
  String get noChatFound => 'Không tìm thấy đoạn chat';

  @override
  String get searchAnotherKeyword => 'Thử tìm với từ khóa khác.';

  @override
  String get createConversationFailed => 'Không tạo được cuộc trò chuyện';

  @override
  String get loadFriendsFailed => 'Không tải được danh sách bạn bè';

  @override
  String get noFriendsFound => 'Không có bạn bè nào';

  @override
  String likesCount(Object count) {
    return '$count lượt thích';
  }

  @override
  String commentsCount(Object count) {
    return '$count bình luận';
  }

  @override
  String sharesCount(Object count) {
    return '$count lượt chia sẻ';
  }

  @override
  String get likeAction => 'Thích';

  @override
  String get commentAction => 'Bình luận';

  @override
  String get shareAction => 'Chia sẻ';

  @override
  String get userLabel => 'Người dùng';

  @override
  String get submitCommentFailed => 'Không thể gửi bình luận. Hãy thử lại.';

  @override
  String get updateCommentFailed => 'Không thể cập nhật bình luận.';

  @override
  String get updateCommentSuccess => 'Đã cập nhật bình luận.';

  @override
  String get deleteCommentFailed => 'Không thể xóa bình luận.';

  @override
  String get deleteCommentSuccess => 'Đã xóa bình luận.';

  @override
  String get commentsTitle => 'Bình luận';

  @override
  String get noCommentsYet => 'Chưa có bình luận nào. Hãy là người đầu tiên!';

  @override
  String get replyingStatus => 'Đang trả lời...';

  @override
  String get replyAction => 'Trả lời';

  @override
  String replyingTo(Object name) {
    return 'Đang trả lời $name';
  }

  @override
  String get writeCommentHint => 'Viết bình luận...';

  @override
  String get writeReplyHint => 'Viết trả lời...';

  @override
  String get timeJustNow => 'Vừa xong';

  @override
  String timeMinutesAgo(Object count) {
    return '$count phút trước';
  }

  @override
  String timeHoursAgo(Object count) {
    return '$count giờ trước';
  }

  @override
  String timeDaysAgo(Object count) {
    return '$count ngày trước';
  }

  @override
  String postAuthorTitle(Object name) {
    return 'Bài viết của $name';
  }

  @override
  String get deletePostTitle => 'Xóa bài viết?';

  @override
  String get deletePostConfirm => 'Hành động này không thể hoàn tác.';

  @override
  String get whatIsHappening => 'Hôm nay bạn thế nào?';

  @override
  String get noPostsTitle => 'Chưa có bài viết';

  @override
  String get loadPostsFailed => 'Chưa tải được bài viết';

  @override
  String get postsEmptyMessage =>
      'Các bài viết của hồ sơ này sẽ xuất hiện tại đây.';

  @override
  String get postUpdated => 'Đã cập nhật bài viết.';

  @override
  String get noChangesToUpdate => 'Không có thay đổi nào để cập nhật.';

  @override
  String get typeMessageHint => 'Nhập tin nhắn...';

  @override
  String get noPhotosTitle => 'Chưa có ảnh';

  @override
  String get photosEmptyMessage =>
      'Ảnh từ các bài viết của hồ sơ này sẽ nằm ở đây.';

  @override
  String get saveImage => 'Lưu ảnh';

  @override
  String get copyImage => 'Sao chép ảnh';

  @override
  String get shareImage => 'Chia sẻ ảnh';

  @override
  String get addFriendAction => 'Kết bạn';

  @override
  String get messageAction => 'Nhắn tin';

  @override
  String get editPostTitle => 'Chỉnh sửa bài viết';

  @override
  String editPostDescriptionWithPhotos(Object count) {
    return 'Đang có $count ảnh (bao gồm ảnh cũ và ảnh mới).';
  }

  @override
  String get editPostDescriptionNoPhotos =>
      'Bạn có thể sửa nội dung hoặc thêm ảnh mới.';

  @override
  String get editPostContentHint => 'Nhập nội dung mới...';

  @override
  String get existingPhotosLabel => 'Ảnh hiện tại';

  @override
  String get newPhotosLabel => 'Ảnh mới thêm';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get noRetainedPhotos => 'Hiện không giữ ảnh cũ nào';

  @override
  String get noNewPhotos => 'Chưa có ảnh mới';

  @override
  String get oldPhotoLabel => 'Ảnh cũ';

  @override
  String get newPhotoLabel => 'Ảnh mới';

  @override
  String get postNeedsContentOrMedia =>
      'Bài viết cần có nội dung hoặc ít nhất một ảnh';

  @override
  String get chatAllTab => 'Tất cả';

  @override
  String get chatGroupsTab => 'Nhóm';

  @override
  String get searchInMessages => 'Tìm kiếm trong tin nhắn';

  @override
  String get newConversationTitle => 'Tạo cuộc trò chuyện mới';

  @override
  String get searchFriends => 'Tìm bạn bè';

  @override
  String get createGroupChatTitle => 'Tạo nhóm chat';

  @override
  String get createGroupChatAction => 'Tạo nhóm';

  @override
  String get createGroupAction => 'Tạo';

  @override
  String get searchMembersHint => 'Tìm thành viên';

  @override
  String get createGroupFailed => 'Không tạo được nhóm chat';

  @override
  String get loadFriendsListFailed => 'Không tải được danh sách bạn bè';

  @override
  String get noFriendsFoundInChat => 'Không có bạn bè nào';

  @override
  String get showAction => 'Hiện';

  @override
  String get deleteChatAction => 'Xóa';

  @override
  String pendingMessagesCount(Object count) {
    return 'Tin nhắn đang chờ ($count)';
  }

  @override
  String get collapseAction => 'Thu gọn';

  @override
  String get expandAction => 'Mở rộng';

  @override
  String get groupDefaultName => 'Nhóm';

  @override
  String get groupCreated => 'Nhóm đã được tạo';

  @override
  String get deleteConversationAction => 'Xóa cuộc trò chuyện';

  @override
  String get audioCallAction => 'Gọi thoại';

  @override
  String get videoCallAction => 'Gọi video';

  @override
  String get viewProfileChatAction => 'Trang cá nhân';

  @override
  String get muteNotificationsAction => 'Tắt thông báo';

  @override
  String get customizationSection => 'Tùy chỉnh';

  @override
  String get themeAction => 'Chủ đề';

  @override
  String get otherActionsSection => 'Hành động khác';

  @override
  String get viewMediaFilesLinks => 'Xem file phương tiện, file và liên kết';
}
