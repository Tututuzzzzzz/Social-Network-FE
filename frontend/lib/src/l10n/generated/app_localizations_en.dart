// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTaglineConnect => 'Connect everyone';

  @override
  String get welcomeTaglineRelationship => 'Open new relationships';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get loginUsernameHint => 'Enter username';

  @override
  String get loginPasswordHint => 'Enter password';

  @override
  String get rememberPassword => 'Remember password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get orText => 'or';

  @override
  String get loginWithGoogle => 'Log in with Google';

  @override
  String get noAccountQuestion => 'No account yet?';

  @override
  String get haveAccountQuestion => 'I already have an account.';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordDescription =>
      'Enter the email linked to your account to receive a new password sent directly to your inbox.';

  @override
  String get enterEmailHint => 'Enter email';

  @override
  String get sendVerificationCode => 'Send new password';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get otpEnterCodeTitle => 'Enter verification code';

  @override
  String otpDescription(Object maskedEmail) {
    return 'To verify your account, enter the 6-digit code we sent to $maskedEmail.';
  }

  @override
  String get otpCodeHint => 'Enter verification code';

  @override
  String get next => 'Next';

  @override
  String get pleaseEnterSixDigitCode => 'Please enter a 6-digit code';

  @override
  String get resendCode => 'Resend code';

  @override
  String get didNotReceiveCode => 'I did not receive the code';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get createNewPasswordTitle => 'Create a new password';

  @override
  String get createNewPasswordDescription =>
      'Create a password with at least 6 letters or digits. Choose one that is hard to guess.';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get invalidOrMismatchedPassword => 'Invalid or mismatched password';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get usernameHint => 'Username';

  @override
  String get reenterPasswordHint => 'Re-enter password';

  @override
  String get pleaseEnterFullName => 'Please enter first and last name';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShortOrMismatch =>
      'Password is too short or does not match';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get profileChooseAccount => 'Choose account';

  @override
  String get profileAccountSwitched => 'Account switched.';

  @override
  String get addAccount => 'Add account';

  @override
  String get addAccountSoon => 'The add account feature will be released soon.';

  @override
  String get settingsAndActivity => 'Settings and activity';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get logoutAction => 'Log out';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get archive => 'Archive';

  @override
  String get switchToProfessionalAccount => 'Switch to professional account';

  @override
  String get switchToBusinessAccount => 'Switch to business account';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get featureInDevelopment => 'Feature in development';

  @override
  String get loadingProfileInfo => 'Loading information...';

  @override
  String get noProfileData => 'No profile data available.';

  @override
  String get postsLabel => 'Posts';

  @override
  String get followersLabel => 'followers';

  @override
  String get followingLabel => 'following';

  @override
  String get editAction => 'Edit';

  @override
  String get shareProfileAction => 'Share profile';

  @override
  String get newLabel => 'New';

  @override
  String get taggedPostsEmpty => 'No tagged posts yet.';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get pageNotImplemented => 'This page has not been implemented yet.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get editAvatarAction => 'Edit photo or avatar';

  @override
  String get pleaseEnterDisplayName => 'Please enter display name';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully.';

  @override
  String get profileUpdateFailed => 'Cannot update profile.';

  @override
  String get profileNoChanges => 'There are no changes to update.';

  @override
  String get profileLoadFailed => 'Cannot load profile.';

  @override
  String get retryAction => 'Try again';

  @override
  String get updateAvatarSuccess => 'Avatar updated successfully.';

  @override
  String get updateAvatarFailed => 'Cannot update avatar.';

  @override
  String get profileSavedLocal => 'Profile information saved to cache.';

  @override
  String get privateAccount => 'Private account';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get genderLabel => 'Gender';

  @override
  String get profileFormSampleData =>
      'Data is currently using a test template.';

  @override
  String get mediaLibrary => 'Library';

  @override
  String get mediaSelectedReady => 'Image selected, ready to continue.';

  @override
  String get chatGroupInfoTitle => 'Group info';

  @override
  String get groupNotFound => 'Group information not found';

  @override
  String membersCount(Object count) {
    return '$count members';
  }

  @override
  String get groupRename => 'Rename group';

  @override
  String get groupChangeAvatar => 'Change group avatar';

  @override
  String get addMember => 'Add member';

  @override
  String get searchMessages => 'Search messages';

  @override
  String get photosAndVideos => 'Photos and videos';

  @override
  String get adminOnlyManageGroupInfo =>
      'Only admins can change group info and add members.';

  @override
  String get memberList => 'Member list';

  @override
  String get youSuffix => 'you';

  @override
  String get adminRole => 'Admin';

  @override
  String get memberRole => 'Member';

  @override
  String get searchHint => 'Search people, posts, places';

  @override
  String get searchLabel => 'Search';

  @override
  String get searchPeople => 'People';

  @override
  String get searchPosts => 'Posts';

  @override
  String get searchPhotos => 'Photos';

  @override
  String get searchPlaces => 'Places';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchSeeAll => 'See all';

  @override
  String get clearAllAction => 'Clear all';

  @override
  String get seeMoreAction => 'See more';

  @override
  String searchResultsCount(Object count) {
    return 'Search results ($count)';
  }

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get lastAdminCannotLeave =>
      'You are the last admin. Transfer admin rights before leaving.';

  @override
  String get groupChatFallback => 'Group chat';

  @override
  String get groupMemberAdded => 'Member added to group';

  @override
  String get leaveGroupQuestion => 'Leave group?';

  @override
  String get leaveGroupNoNewMessages =>
      'You will no longer receive new messages from this group.';

  @override
  String get selectNewAdminBeforeLeave =>
      'You are the last admin. Choose a new admin before leaving.';

  @override
  String get noMemberToTransfer => 'No members available for transfer.';

  @override
  String get currentRoleAdmin => 'Current role: Admin';

  @override
  String get currentRoleMember => 'Current role: Member';

  @override
  String get cannotLeaveGroupCheckAdmin =>
      'Cannot leave group. Please recheck admin permissions.';

  @override
  String get leftGroupSuccess => 'You have successfully left the group.';

  @override
  String get handoverAndLeaveSuccess =>
      'Admin rights transferred and you left the group successfully.';

  @override
  String get secondConfirmation => 'Confirm again';

  @override
  String get aboutToHandoverAndLeave =>
      'You are about to transfer admin rights and leave the group.';

  @override
  String get newAdminWillBe => 'Will become the new admin';

  @override
  String get afterConfirmLeaveImmediately =>
      'After confirmation, you will leave the group immediately.';

  @override
  String get goBack => 'Go back';

  @override
  String get confirmHandover => 'Confirm transfer';

  @override
  String get adminOnlyAction => 'Only admins can perform this action.';

  @override
  String get chatInviteLink => 'Invite link';

  @override
  String get inviteLinkCopied => 'Group invite link copied.';

  @override
  String get addPeople => 'Add people';

  @override
  String youBlockedUser(Object name) {
    return 'You blocked $name';
  }

  @override
  String youRestrictedUser(Object name) {
    return 'You restricted $name';
  }

  @override
  String get noOnlineOrReadStatus =>
      'They will not see your active status or read receipts.';

  @override
  String get blockAction => 'Block';

  @override
  String get unblockAction => 'Unblock';

  @override
  String get unrestrictAction => 'Unrestrict';

  @override
  String get onlyAdminCanAddMembers => 'Only admins can add members.';

  @override
  String get messagesSearchHint => 'Search';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get pendingMessages => 'Pending messages';

  @override
  String get noConversationFound => 'No conversations found.';

  @override
  String get chatPinned => 'Chat pinned.';

  @override
  String get chatUnpinned => 'Chat unpinned.';

  @override
  String get chatHidden => 'Chat hidden.';

  @override
  String get chatDeleted => 'Chat deleted.';

  @override
  String get pinAction => 'Pin';

  @override
  String get unpinAction => 'Unpin';

  @override
  String get hideAction => 'Hide';

  @override
  String get deleteAction => 'Delete';

  @override
  String get mutedNow => 'Notifications muted';

  @override
  String get feedNotificationSoon => 'Notifications will be updated soon.';

  @override
  String get sessionExpiredRelogin => 'Session expired. Please log in again.';

  @override
  String get emptyNoPosts => 'No posts yet.';

  @override
  String get emptyFollowFriends => 'Check back later or follow more friends.';

  @override
  String get shareSoon => 'Share feature will be updated soon.';

  @override
  String get saveSoon => 'Save post feature will be updated soon.';

  @override
  String get createPostCannotPickGallery => 'Cannot pick images from gallery.';

  @override
  String get createPostCannotOpenCamera => 'Cannot open camera.';

  @override
  String get createPostTitle => 'Create post';

  @override
  String get postAction => 'Post';

  @override
  String get captionHint => 'What\'s on your mind?';

  @override
  String get addMediaForPost => 'Add photo/video to post';

  @override
  String get pickFromLibrary => 'Pick from library';

  @override
  String get libraryLabel => 'Photos';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get templateLabel => 'Post template';

  @override
  String get templateSoon => 'Post templates will be updated soon.';

  @override
  String get friendsSearchHint => 'Search friends';

  @override
  String cannotOpenChat(Object error) {
    return 'Cannot open chat: $error';
  }

  @override
  String get placeholderLastMessage => 'This is a sample message content.';

  @override
  String get messageInputHint => 'Type a message...';

  @override
  String get bioLabel => 'Bio';

  @override
  String get myLoveLabel => 'My Love';

  @override
  String get searchInConversationHint => 'Search in conversation';

  @override
  String get enterKeywordToSearch => 'Enter a keyword to search messages';

  @override
  String get noMatchingResults => 'No matching results found.';

  @override
  String get youLabel => 'You';

  @override
  String get enterNicknameHint => 'Enter nickname';

  @override
  String nicknameRemoved(Object name) {
    return 'Removed nickname for $name';
  }

  @override
  String nicknameUpdated(Object name) {
    return 'Updated nickname for $name';
  }

  @override
  String nicknameVisibleInChat(Object name) {
    return 'Everyone in this chat will see this nickname for $name.';
  }

  @override
  String get groupNameHint => 'Group name';

  @override
  String get invitedMembers => 'Invited members';

  @override
  String get searchGeneric => 'Search';

  @override
  String get safetyProfile => 'Profile';

  @override
  String get restrictAction => 'Restrict';

  @override
  String get blockAccount => 'Block account';

  @override
  String get unblockAccount => 'Unblock account';

  @override
  String get nicknameAction => 'Nickname';

  @override
  String get createGroupChat => 'Create group chat';

  @override
  String get optionsLabel => 'Options';

  @override
  String get muteOffLabel => 'Off';

  @override
  String get photosAndVideoTitle => 'Photos and Video';

  @override
  String get viewAll => 'See all';

  @override
  String get blockedMediaHidden =>
      'Photo and video content is hidden because you blocked this account.';

  @override
  String get mute10Minutes => '10 minutes';

  @override
  String get mute30Minutes => '30 minutes';

  @override
  String get mute1Hour => '1 hour';

  @override
  String get mute2Hours => '2 hours';

  @override
  String get mute12Hours => '12 hours';

  @override
  String get mute24Hours => '24 hours';

  @override
  String get mute48Hours => '48 hours';

  @override
  String get muteConversationTitle => 'Mute chat notifications';

  @override
  String get turnOnNotifications => 'Turn on notifications';

  @override
  String get grantAdmin => 'Grant admin role';

  @override
  String get revokeAdmin => 'Revoke admin role';

  @override
  String get revokeAdminLocked => 'Revoke admin role (locked)';

  @override
  String get onlyAdminCanChangeRole => 'Only admins can change roles';

  @override
  String get privateMessage => 'Private message';

  @override
  String get thisIsYourAccount => 'This is your account';

  @override
  String get newGroupTitle => 'New group';

  @override
  String get editGroupTitle => 'Edit group';

  @override
  String get createAction => 'Create';

  @override
  String get peopleWhoCanContactYou => 'People who can contact you';

  @override
  String get editNicknameTitle => 'Edit nickname';

  @override
  String get groupRoleTitle => 'Group role';

  @override
  String get memberIdTitle => 'Member ID';

  @override
  String adminGrantedTo(Object name) {
    return 'Granted admin role to $name';
  }

  @override
  String get cannotGrantAdmin => 'Cannot grant admin role';

  @override
  String adminRevokedFrom(Object name) {
    return 'Revoked admin role from $name';
  }

  @override
  String get cannotRevokeAdmin => 'Cannot revoke admin role';

  @override
  String get cannotRevokeOwnAdminTooltip =>
      'You cannot revoke your own admin role. Grant admin to someone else first.';

  @override
  String get cannotRevokeOwnAdmin => 'You cannot revoke your own admin role';

  @override
  String get onlyAdminCanGrantOrRevokeTooltip =>
      'Only admins can grant or revoke admin roles.';

  @override
  String get noAdminPermissionForAction =>
      'You do not have admin permission for this action';

  @override
  String get cannotRevokeLastAdmin =>
      'Cannot revoke the last admin role in the group.';

  @override
  String get youAreCurrentAdmin => 'You are the current admin';

  @override
  String get adminHasFullControl => 'Admins have full control';

  @override
  String get canGrantOrRevokeForOthers =>
      'You can grant/revoke admin roles for other members.';

  @override
  String get youHaveAdminRights => 'You have admin rights';

  @override
  String get canChangeMemberRoles =>
      'You can change member roles in this group.';

  @override
  String get noPermissionChangeRole =>
      'You do not have permission to change roles';

  @override
  String get onlyAdminCanGrantOrRevoke =>
      'Only admins are allowed to grant/revoke admin roles.';

  @override
  String get mutePriorityHint =>
      'Highest priority: cancel all current mute states.';

  @override
  String get muteUntilTurnedOn => 'Until turned back on';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get reelsTitle => 'Reels';

  @override
  String get postOptionAddToFavorites => 'Add to favorites';

  @override
  String get postOptionAboutThisAccount => 'About this account';

  @override
  String get postOptionHidePost => 'Hide post';

  @override
  String get postOptionReport => 'Report';

  @override
  String get postOptionAddToFavoritesDone => 'Added to favorites';

  @override
  String get postOptionHidePostDone => 'Post hidden';

  @override
  String get postOptionReportDone => 'Report submitted successfully';

  @override
  String postOptionReportDoneWithReason(Object reason) {
    return 'Report submitted with reason: $reason';
  }

  @override
  String get postReportTitle => 'Report post';

  @override
  String get postReportSelectReason => 'Select the most relevant reason';

  @override
  String get postReportSubmit => 'Submit report';

  @override
  String get postReportReasonSpam => 'Spam';

  @override
  String get postReportReasonHarassment => 'Harassment or bullying';

  @override
  String get postReportReasonFalseInfo => 'False information';

  @override
  String get postReportReasonHateSpeech => 'Hate speech';

  @override
  String get postReportReasonViolence => 'Violence or dangerous content';

  @override
  String get postReportReasonOther => 'Other reason';

  @override
  String get postOptionAllHiddenTitle => 'You have hidden all posts';

  @override
  String get postOptionAllHiddenDescription =>
      'Refresh to load new content or wait for other posts.';

  @override
  String get followingStatus => 'Following';

  @override
  String get yourStory => 'Your Story';

  @override
  String viewAllComments(Object count) {
    return 'View all $count comments';
  }

  @override
  String likesCountText(Object count) {
    return '$count likes';
  }

  @override
  String get followAction => 'Follow';

  @override
  String get recentSearchTitle => 'Recent search';

  @override
  String get friendRequestSent => 'Request sent';

  @override
  String get friendRequestSendSuccess => 'Friend request sent';

  @override
  String get friendRequestSendError => 'Failed to send friend request';

  @override
  String get acceptFriendRequest => 'Accept';

  @override
  String get rejectFriendRequest => 'Reject';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get titleSearch => 'Search';

  @override
  String get titleReels => 'Reels';

  @override
  String get titleChat => 'Chat';

  @override
  String get friends => 'Friends';

  @override
  String get friendRequestAccepted => 'Friend request accepted';

  @override
  String get yourFriendRequestAccepted =>
      'Your friend request has been accepted';

  @override
  String get friendRequestReceived => 'sent you a friend request';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Mochi';

  @override
  String get onboardingWelcomeDesc =>
      'A social network connecting people, sharing meaningful moments in your life.';

  @override
  String get onboardingConnectTitle => 'Connect with Friends';

  @override
  String get onboardingConnectDesc =>
      'Search and connect with friends everywhere. Create beautiful memories together.';

  @override
  String get onboardingShareTitle => 'Share Your Passion';

  @override
  String get onboardingShareDesc =>
      'Post articles, photos, and videos of the things you love every day.';

  @override
  String get onboardingChatTitle => 'Unlimited Chat';

  @override
  String get onboardingChatDesc =>
      'Free high-quality messages and calls. Keep in touch with loved ones.';

  @override
  String get onboardingStart => 'Start Now';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get notificationTabPosts => 'Posts';

  @override
  String get notificationTabFriends => 'Friends';

  @override
  String get notificationEmptyPosts => 'No post notifications yet';

  @override
  String get notificationEmptyFriends => 'No friend requests yet';

  @override
  String get notificationLiked => 'liked your post';

  @override
  String get notificationCommented => 'commented on your post';

  @override
  String get notificationFollowed => 'started following you';

  @override
  String get navHome => 'Home';

  @override
  String get navCreate => 'Create';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get userDefaultName => 'User';

  @override
  String get profilePersonalTitle => 'Personal Profile';

  @override
  String get noSessionTitle => 'No Active Session';

  @override
  String get noSessionMessage => 'Please login again to view your profile.';

  @override
  String get retry => 'Retry';

  @override
  String get noBio => 'No bio yet.';

  @override
  String get friendsLabel => 'Friends';

  @override
  String get photosLabel => 'Photos';

  @override
  String get unknownRecipient => 'Unknown recipient for the message';

  @override
  String get unknownSenderLabel => 'Unknown';

  @override
  String get deletedMessageLabel => 'Deleted message';

  @override
  String get todayLabel => 'Today';

  @override
  String get attachmentLabel => 'Attachment';

  @override
  String get messagePickMediaFailed => 'Cannot pick or capture media.';

  @override
  String get startChatting => 'Start chatting...';

  @override
  String get timeNow => 'now';

  @override
  String get conversationTitle => 'Conversation';

  @override
  String get searchCategoryTrending => 'Trending';

  @override
  String get searchCategoryTravel => 'Travel';

  @override
  String get searchCategoryFood => 'Food';

  @override
  String get searchCategoryMusic => 'Music';

  @override
  String get searchCategoryLandscape => 'Landscape';

  @override
  String get searchCategoryTech => 'Tech';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get peopleLabel => 'People';

  @override
  String get discoverLabel => 'Discover';

  @override
  String get exploreLabel => 'Explore';

  @override
  String get deleteChatTitle => 'Delete chat';

  @override
  String deleteChatConfirm(Object name) {
    return 'Do you want to delete the chat with $name?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get loadMessagesFailed => 'Failed to load messages';

  @override
  String get noChatFound => 'No chat found';

  @override
  String get searchAnotherKeyword => 'Try searching with another keyword.';

  @override
  String get createConversationFailed => 'Failed to create conversation';

  @override
  String get loadFriendsFailed => 'Failed to load friends list';

  @override
  String get noFriendsFound => 'No friends found';

  @override
  String likesCount(Object count) {
    return '$count likes';
  }

  @override
  String commentsCount(Object count) {
    return '$count comments';
  }

  @override
  String sharesCount(Object count) {
    return '$count shares';
  }

  @override
  String get likeAction => 'Like';

  @override
  String get commentAction => 'Comment';

  @override
  String get shareAction => 'Share';

  @override
  String get userLabel => 'User';

  @override
  String get submitCommentFailed => 'Failed to post comment. Please try again.';

  @override
  String get updateCommentFailed => 'Failed to update comment.';

  @override
  String get updateCommentSuccess => 'Comment updated.';

  @override
  String get deleteCommentFailed => 'Failed to delete comment.';

  @override
  String get deleteCommentSuccess => 'Comment deleted.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet. Be the first to comment!';

  @override
  String get replyingStatus => 'Replying...';

  @override
  String get replyAction => 'Reply';

  @override
  String replyingTo(Object name) {
    return 'Replying to $name';
  }

  @override
  String get writeCommentHint => 'Write a comment...';

  @override
  String get writeReplyHint => 'Write a reply...';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String postAuthorTitle(Object name) {
    return '$name\'s post';
  }

  @override
  String get deletePostTitle => 'Delete post?';

  @override
  String get deletePostConfirm => 'This action cannot be undone.';

  @override
  String get whatIsHappening => 'What\'s happening?';

  @override
  String get noPostsTitle => 'No posts yet';

  @override
  String get loadPostsFailed => 'Failed to load posts';

  @override
  String get postsEmptyMessage => 'Posts from this profile will appear here.';

  @override
  String get postUpdated => 'Post updated.';

  @override
  String get noChangesToUpdate => 'No changes to update.';

  @override
  String get typeMessageHint => 'Type a message...';

  @override
  String get noPhotosTitle => 'No photos yet';

  @override
  String get photosEmptyMessage =>
      'Photos from this profile\'s posts will appear here.';

  @override
  String get saveImage => 'Save image';

  @override
  String get copyImage => 'Copy image';

  @override
  String get shareImage => 'Share image';

  @override
  String get addFriendAction => 'Add friend';

  @override
  String get messageAction => 'Message';

  @override
  String get editPostTitle => 'Edit Post';

  @override
  String editPostDescriptionWithPhotos(Object count) {
    return 'You have $count photos (including old and new).';
  }

  @override
  String get editPostDescriptionNoPhotos =>
      'You can edit the content or add new photos.';

  @override
  String get editPostContentHint => 'Enter new content...';

  @override
  String get existingPhotosLabel => 'Current photos';

  @override
  String get newPhotosLabel => 'Newly added photos';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get noRetainedPhotos => 'No old photos kept';

  @override
  String get noNewPhotos => 'No new photos yet';

  @override
  String get oldPhotoLabel => 'Old';

  @override
  String get newPhotoLabel => 'New';

  @override
  String get postNeedsContentOrMedia =>
      'Post needs content or at least one photo';

  @override
  String get chatAllTab => 'All';

  @override
  String get chatGroupsTab => 'Groups';

  @override
  String get searchInMessages => 'Search in messages';

  @override
  String get newConversationTitle => 'New conversation';

  @override
  String get searchFriends => 'Search friends';

  @override
  String get createGroupChatTitle => 'Create group chat';

  @override
  String get createGroupChatAction => 'Create group';

  @override
  String get createGroupAction => 'Create';

  @override
  String get searchMembersHint => 'Search members';

  @override
  String get createGroupFailed => 'Failed to create group chat';

  @override
  String get loadFriendsListFailed => 'Failed to load friends list';

  @override
  String get noFriendsFoundInChat => 'No friends found';

  @override
  String get showAction => 'Show';

  @override
  String get deleteChatAction => 'Delete';

  @override
  String pendingMessagesCount(Object count) {
    return 'Pending messages ($count)';
  }

  @override
  String get collapseAction => 'Collapse';

  @override
  String get expandAction => 'Expand';

  @override
  String get groupDefaultName => 'Group';

  @override
  String get groupCreated => 'Group created';

  @override
  String get deleteConversationAction => 'Delete conversation';

  @override
  String get audioCallAction => 'Audio call';

  @override
  String get videoCallAction => 'Video call';

  @override
  String get viewProfileChatAction => 'View profile';

  @override
  String get muteNotificationsAction => 'Mute notifications';

  @override
  String get customizationSection => 'Customization';

  @override
  String get themeAction => 'Theme';

  @override
  String get themeModeLabel => 'Light/Dark mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get otherActionsSection => 'Other actions';

  @override
  String get viewMediaFilesLinks => 'View media, files & links';
}
