class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080'; // emulator → localhost
  // For physical device replace with your machine's local IP, e.g. http://192.168.1.x:8080

  static const String loginUrl = '$baseUrl/auth/login';
  static const String opportunitiesUrl = '$baseUrl/opportunity/';
}
