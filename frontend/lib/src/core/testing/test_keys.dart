import 'package:flutter/foundation.dart';

class TestKeys {
  static const welcomeLoginButton = ValueKey('welcome.login');
  static const welcomeRegisterButton = ValueKey('welcome.register');

  static const loginUsernameField = ValueKey('login.username');
  static const loginPasswordField = ValueKey('login.password');
  static const loginRememberCheckbox = ValueKey('login.remember');
  static const loginSubmitButton = ValueKey('login.submit');
  static const loginRegisterLink = ValueKey('login.register.link');

  static const registerFirstNameField = ValueKey('register.firstName');
  static const registerLastNameField = ValueKey('register.lastName');
  static const registerUsernameField = ValueKey('register.username');
  static const registerEmailField = ValueKey('register.email');
  static const registerPasswordField = ValueKey('register.password');
  static const registerConfirmField = ValueKey('register.confirm');
  static const registerSubmitButton = ValueKey('register.submit');
  static const registerSuccessStartButton = ValueKey('register.success.start');

  static const navHome = ValueKey('nav.home');
  static const navCreate = ValueKey('nav.create');
  static const navNotifications = ValueKey('nav.notifications');
  static const navProfile = ValueKey('nav.profile');

  static const feedSearchButton = ValueKey('feed.search');
  static const feedChatButton = ValueKey('feed.chat');

  static const createPostCaptionField = ValueKey('createPost.caption');
  static const createPostSubmitButton = ValueKey('createPost.submit');
  static const createPostCloseButton = ValueKey('createPost.close');
  static const createPostLibraryButton = ValueKey('createPost.library');
  static const createPostCameraButton = ValueKey('createPost.camera');
  static const createPostTemplateButton = ValueKey('createPost.template');

  static const chatNewConversationButton = ValueKey('chat.newConversation');
  static Key chatThreadItem(int index) => ValueKey('chat.thread.$index');
  static Key newConversationFriend(int index) =>
      ValueKey('chat.newFriend.$index');

  static const messageInputField = ValueKey('chat.message.input');
  static const messageSendButton = ValueKey('chat.message.send');

  static const profileSettingsButton = ValueKey('profile.settings');
  static const profileEditAction = ValueKey('profile.edit');

  static const editProfileDisplayNameField =
      ValueKey('profile.edit.displayName');
  static const editProfileBioField = ValueKey('profile.edit.bio');
  static const editProfilePhoneField = ValueKey('profile.edit.phone');
  static const editProfileSaveButton = ValueKey('profile.edit.save');

  // New keys for E2E flows
  static const profileLogoutAction = ValueKey('profile.logout');
  static const postLikeButton = ValueKey('post.like');
  static const postCommentButton = ValueKey('post.comment');
  static const postCommentTextField = ValueKey('post.comment.input');
  static const postCommentSendButton = ValueKey('post.comment.send');
  static const searchTextField = ValueKey('search.input');
}
