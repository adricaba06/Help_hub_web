import 'dart:convert';

class UserResponse {
  final int id;
  final String email;
  final String displayName;
  final String role;

  UserResponse({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] as int,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role,
      };

  static UserResponse fromRawJson(String str) =>
      UserResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}
