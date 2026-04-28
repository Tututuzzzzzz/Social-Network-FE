enum AppRoutes {
  welcome(path: '/'),
  login(path: '/login'),
  register(path: '/register'),
  auth(path: '/auth'),
  authLogin(path: '/auth/login'),
  authRegister(path: '/auth/register'),
  home(path: '/home'),
  homeSearch(path: '/home/search'),
  chat(path: '/chat'),
  notifications(path: '/notifications'),
  chatMochiChatRoom(path: '/chat/room/:threadId'),
  editProfile(path: '/profile/edit'),
  profile(path: '/profile'),
  otherProfile(path: '/profile/:userId');

  final String path;
  const AppRoutes({required this.path});
}
