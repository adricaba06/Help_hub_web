import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class Userservice {
  Userservice({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? _resolveBaseUrl();

  final http.Client _client;
  final String baseUrl;

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      //Las x las hay que cambiar cuando llegue a clase por la ip del ordenador
        return 'http://XXXXXXXXXXXXXXXX:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:8080';
    }
  }

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
