class UserResponse {
  final int id;
  final String email;
  final String displayName;
  final String role;
  final String? profileImage;

  UserResponse({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.profileImage,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] as int,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        role: json['role'] as String,
        profileImage: json['profileImage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role,
        'profileImage': profileImage,
      };
}
