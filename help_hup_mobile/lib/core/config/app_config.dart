class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String loginUrl = '$baseUrl/auth/login';
  static const String logoutUrl = '$baseUrl/auth/logout';
  static const String opportunitiesUrl = '$baseUrl/opportunity/';
  static const String profileUrl = '$baseUrl/users/me';
  static const String favoritesUrl = '$baseUrl/favorites/me';
  static const String editProfileUrl = '$baseUrl/user/profile';
}
