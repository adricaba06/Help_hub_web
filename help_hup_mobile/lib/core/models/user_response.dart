import 'dart:convert';

class UserResponse {
  final String id;
  final String name;
  final String email;

  const UserResponse({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      id: map['id'].toString(),
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email};

  String toJson() => jsonEncode(toMap());

  factory UserResponse.fromJson(String source) =>
      UserResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
