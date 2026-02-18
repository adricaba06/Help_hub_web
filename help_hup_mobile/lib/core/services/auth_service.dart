import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../interfaces/auth_interface.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/user_response.dart';

class AuthService implements AuthInterface {
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    // First, try the real API
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: request.toRawJson(),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return AuthResponse.fromRawJson(response.body);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Credenciales incorrectas. Revisa tu email y contraseña.');
      }

      // Try to parse a server error message
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final msg = body['message'] ?? body['error'] ?? body['detail'];
        if (msg != null) throw Exception(msg.toString());
      } catch (_) {}

      throw Exception('Error del servidor (${response.statusCode}).');
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('No se pudo conectar con el servidor. Comprueba tu conexión o la IP en AppConfig.');
    }
  }

  /// Returns an AuthResponse using the hardcoded test token plus a mock user
  /// derived from known test credentials. Use this when the API is unreachable.
  AuthResponse buildTestResponse(String email) {
    final roleMap = {
      'voluntario@helphub.com': ('USER', 'Voluntario Demo'),
      'manager@helphub.com': ('MANAGER', 'Manager Demo'),
      'admin@helphub.com': ('ADMIN', 'Admin Demo'),
    };
    final entry = roleMap[email.toLowerCase()];
    final role = entry?.$1 ?? 'USER';
    final name = entry?.$2 ?? email;

    return AuthResponse(
      token: AppConfig.testToken,
      user: UserResponse(id: 1, email: email, displayName: name, role: role),
    );
  }
}
