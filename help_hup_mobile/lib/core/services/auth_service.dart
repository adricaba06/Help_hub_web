import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/auth_response.dart';

class AuthService {
  // Llama a la API y devuelve el token + datos del usuario
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConfig.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Login correcto → convertimos el JSON a un objeto Dart
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Credenciales incorrectas.');
    } else {
      throw Exception('Error del servidor (${response.statusCode}).');
    }
  }
}
