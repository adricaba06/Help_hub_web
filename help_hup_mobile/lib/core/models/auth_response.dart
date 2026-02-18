import 'dart:convert';
import 'user_response.dart';

class AuthResponse {
  final String token;
  final UserResponse user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      );

  static AuthResponse fromRawJson(String str) =>
      AuthResponse.fromJson(json.decode(str));
}
