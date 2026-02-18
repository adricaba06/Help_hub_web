import 'package:flutter/material.dart';
import '../../../core/models/login_request.dart';
import '../../../core/models/user_response.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthStatus _status = AuthStatus.initial;
  UserResponse? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserResponse? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final loggedIn = await _storageService.isLoggedIn();
    if (loggedIn) {
      _currentUser = await _storageService.getUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, {bool useTestToken = false}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = useTestToken
          ? _authService.buildTestResponse(email)
          : await _authService.login(LoginRequest(email: email, password: password));

      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      _currentUser = response.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.clear();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
