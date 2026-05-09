enum AppRoutes {
  welcome(path: '/'),
  onboarding(path: '/onboarding'),
  login(path: '/login'),
  register(path: '/register'),
  auth(path: '/auth'),
  authLogin(path: '/auth/login'),
  authRegister(path: '/auth/register'),
  home(path: '/home'),
  homeSearch(path: '/home/search'),
  chat(path: '/chat'),
  chatNewConversation(path: '/chat/new'),
  notifications(path: '/notifications'),
  chatMochiChatRoom(path: '/chat/room/:threadId'),
  chatConversationManage(path: '/chat/room/:threadId/manage'),
  editProfile(path: '/profile/edit'),
  profile(path: '/profile'),
  createPost(path: '/create-post'),
  stories(path: '/stories'),
  forgotPassword(path: '/forgot-password'),
  verificationCode(path: '/verification-code'),
  resetPassword(path: '/reset-password'),
  registerSuccess(path: '/register-success'),
  otherProfile(path: '/profile/:userId');

  final String path;
  const AppRoutes({required this.path});
}
