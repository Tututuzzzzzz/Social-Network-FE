enum AppRoutePath {
  login('/login', 'login'),
  admin('/', 'admin');

  const AppRoutePath(this.path, this.name);

  final String path;
  final String name;
}
