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
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => '{"id":"$id","name":"$name","email":"$email"}';

  factory UserResponse.fromJson(String source) {
    final map = <String, dynamic>{};
    final pairs = source
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('"', '')
        .split(',');
    for (final pair in pairs) {
      final kv = pair.split(':');
      if (kv.length == 2) map[kv[0].trim()] = kv[1].trim();
    }
    return UserResponse.fromMap(map);
  }
}
