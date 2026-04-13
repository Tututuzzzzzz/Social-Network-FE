enum AppRoutes {
  welcome(path: "/"),
  login(path: "/login"),
  register(path: "/register"),
  home(path: "/home"),
  postsFeed(path: "/posts/feed"),
  postsCreate(path: "/posts/create");

  final String path;
  const AppRoutes({required this.path});
}
