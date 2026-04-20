enum AppRoutes {
  welcome(path: '/'),
  login(path: '/login'),
  register(path: '/register'),
  auth(path: '/auth'),
  authLogin(path: '/auth/login'),
  authRegister(path: '/auth/register'),
  home(path: '/home'),
  homeSearch(path: '/home/search'),
  reels(path: '/reels'),
  chat(path: '/chat'),
  chatMochiChatRoom(path: '/chat/room/:threadId'),
  editProfile(path: '/profile/edit'),
  profile(path: '/profile');

  final String path;
  const AppRoutes({required this.path});
}
