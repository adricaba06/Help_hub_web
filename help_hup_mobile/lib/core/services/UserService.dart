import 'package:http/http.dart' as http;
import 'dart:convert';

class Userservice {
  Userservice({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
          'role': role,
        }),
      );

      final dynamic decoded = jsonDecode(response.body);
      final data =decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final message = data['message']?.toString() ?? 'Error en el registro';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('No se pudo completar el registro');
    }
  }
}
