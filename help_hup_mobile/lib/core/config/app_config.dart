class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080'; // emulator → localhost
  // For physical device replace with your machine's local IP, e.g. http://192.168.1.x:8080

  static const String loginUrl = '$baseUrl/auth/login';

  // Hardcoded token for testing (bypasses API login when isTestMode = true)
  static const String testToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9'
      '.eyJzdWIiOiIxIiwiaWF0IjoxNzcxNDE1NTExLCJleHAiOjE3NzE1MDE5MTF9'
      '.rgq7Y2YyMkD3t0vvxkNZQxt20FwJZS1ZByreevAKhBlmHgi0IOtr6MCDfWpz4iinvOwvbPAYHvyfjs5-cX5CMw';
}
