import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/user_response.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final StorageService storageService;

  AuthBloc(this.authService, this.storageService) : super(AuthInitial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthErrorCleared>(_onErrorCleared);

    add(AuthCheckSessionRequested());
  }

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await storageService.isLoggedIn();

    if (hasToken) {
      final user = await storageService.getUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await authService.login(event.email, event.password);

      await storageService.saveToken(response.token);
      await storageService.saveUser(response.user);

      emit(AuthAuthenticated(user: response.user));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await storageService.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await authService.logout(token);
      } catch (_) {
        // Local cleanup proceeds even when backend logout fails.
      }
    }

    await storageService.clear();
    emit(AuthUnauthenticated());
  }

  void _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthUnauthenticated());
  }
}
