import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_response.dart';

// Guarda y recupera datos en el móvil (aunque cierres la app)
class StorageService {
  // Guarda el token JWT en el móvil
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Obtiene el token guardado (null si no hay sesión)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Guarda los datos del usuario en el móvil
  Future<void> saveUser(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // Obtiene los datos del usuario guardado
  Future<UserResponse?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString('user');
    if (texto == null) return null;
    return UserResponse.fromJson(jsonDecode(texto));
  }

  // Comprueba si hay sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Borra todo al hacer logout
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
