class AppEnvConfig {
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api',
  );

  static bool get isProduction {
    final normalized = appEnv.trim().toLowerCase();
    return normalized == 'prod' || normalized == 'production';
  }

  static bool get isDevelopment => !isProduction;
}
