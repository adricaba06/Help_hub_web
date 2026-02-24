class Organization {
  final int id;
  final String name;
  final String city;
  final String? logoFieldId;
  final String? coverFieldId;
  final String? description;
  final SimpleManager? manager;

  Organization({
    required this.id,
    required this.name,
    required this.city,
    this.logoFieldId,
    this.coverFieldId,
    this.description,
    this.manager,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: _parseInt(json['id']),
        name: (json['name'] ?? '') as String,
        city: (json['city'] ?? '') as String,
        logoFieldId: _parseNullableString(json['logoFieldId']),
        coverFieldId: _parseNullableString(json['coverFieldId']),
        description: json['description'] as String?,
        manager: json['managerDto'] != null
            ? SimpleManager.fromJson(json['managerDto'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'logoFieldId': logoFieldId,
        'coverFieldId': coverFieldId,
        'description': description,
        'managerDto': manager?.toJson(),
      };
}

class SimpleManager {
  final int? id;
  final String name;

  SimpleManager({this.id, required this.name});

  factory SimpleManager.fromJson(Map<String, dynamic> json) =>
      SimpleManager(
        id: _parseNullableInt(json['id']),
        name: (json['name'] ?? json['fullName'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Invalid int value: $value');
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is num) return value.toInt().toString();
  return null;
}
