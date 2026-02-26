import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_response.dart';
import 'storage_service.dart';

class ProfileService {
  final StorageService _storage = StorageService();

  // Máximo tamaño de archivo: 5MB
  static const int maxFileSize = 5 * 1024 * 1024;

  // Tipos MIME permitidos
  static const List<String> allowedMimeTypes = ['image/jpeg', 'image/png'];

  // ...existing code...

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

  Future<UserResponse> editProfile({required String newName}) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    final response = await http.put(
      Uri.parse(AppConfig.editProfileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'displayName': newName,
      }),
    );

    if (response.statusCode == 200) {
      final user = UserResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      await _storage.saveUser(user);
      return user;
    }

    throw Exception('Error al actualizar el perfil (${response.statusCode}).');
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesion activa.');
    }

    final response = await http.post(
      Uri.parse(AppConfig.changePasswordUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 400) {
      throw Exception('La contrasena actual no es valida.');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sesion expirada. Inicia sesion de nuevo.');
    }

    throw Exception('Error al cambiar la contrasena (${response.statusCode}).');
  }

  Future<UserResponse> uploadProfilePicture({required File imageFile}) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    // Validar que el archivo existe
    if (!await imageFile.exists()) {
      throw Exception('El archivo no existe.');
    }

    // Validar tamaño del archivo
    final fileSize = await imageFile.length();
    if (fileSize > maxFileSize) {
      throw Exception('La imagen es demasiado grande. Máximo: 5MB');
    }

    // Validar tipo MIME
    final mimeType = _getMimeType(imageFile.path);
    if (!allowedMimeTypes.contains(mimeType)) {
      throw Exception('Formato de imagen no permitido. Usa PNG o JPEG.');
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/user/profile/picture'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final user = UserResponse.fromJson(
          jsonDecode(responseBody) as Map<String, dynamic>,
        );
        await _storage.saveUser(user);
        return user;
      }

      if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }

      if (response.statusCode == 400) {
        throw Exception('Archivo inválido. Intenta con otra imagen.');
      }

      throw Exception('Error al subir la foto (${response.statusCode}).');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al procesar la foto: $e');
    }
  }

  // Helper para detectar MIME type basado en extensión
  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
