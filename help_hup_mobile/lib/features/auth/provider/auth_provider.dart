import 'package:flutter/material.dart';
import '../../../core/models/user_response.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

// Estados posibles de la autenticación
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // Estado actual y datos del usuario
  AuthStatus status = AuthStatus.initial;
  UserResponse? currentUser;
  String? errorMessage;

  AuthProvider() {
    // Al arrancar la app, comprobamos si ya había sesión guardada
    _comprobarSesionGuardada();
  }

  Future<void> _comprobarSesionGuardada() async {
    final hayToken = await _storageService.isLoggedIn();
    if (hayToken) {
      currentUser = await _storageService.getUser();
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Hace login contra la API
  Future<void> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // Llama a la API y obtiene token + usuario
      final respuesta = await _authService.login(email, password);

      // Guarda el token y el usuario en el móvil
      await _storageService.saveToken(respuesta.token);
      await _storageService.saveUser(respuesta.user);

      // Actualiza el estado
      currentUser = respuesta.user;
      status = AuthStatus.authenticated;
    } catch (e) {
      // Si algo falla, guardamos el mensaje de error
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      status = AuthStatus.error;
    }

    notifyListeners();
  }

  // Cierra sesión y borra los datos guardados
  Future<void> logout() async {
    await _storageService.clear();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Limpia el mensaje de error
  void clearError() {
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
