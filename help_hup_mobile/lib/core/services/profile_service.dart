import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_response.dart';
import 'storage_service.dart';

class ProfileService {
  final StorageService _storage = StorageService();

  Future<UserResponse> getMyProfile() async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.get(
      Uri.parse(AppConfig.profileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final user = UserResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _storage.saveUser(user);
      return user;
    }

    if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Inicia sesión de nuevo.');
    }

    if (response.statusCode == 404) {
      final localUser = await _storage.getUser();
      if (localUser != null) {
        return localUser;
      }
      throw Exception('Perfil no encontrado.');
    }

    throw Exception('Error al cargar perfil (${response.statusCode}).');
  }
}
