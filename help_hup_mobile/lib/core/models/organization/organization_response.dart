// lib/models/organization/organization.dart

class Organization {
  final int id;
  final String name;
  final String city;
  final int? logoFieldId;
  final SimpleManager? manager;

  Organization({
    required this.id,
    required this.name,
    required this.city,
    this.logoFieldId,
    this.manager,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        id: json['id'],
        name: json['name'],
        city: json['city'],
        logoFieldId: json['logoFieldId'],
        manager: json['managerDto'] != null
            ? SimpleManager.fromJson(json['managerDto'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'logoFieldId': logoFieldId,
        'managerDto': manager?.toJson(),
      };
}

class SimpleManager {
  final String name;

  SimpleManager({required this.name});

  factory SimpleManager.fromJson(Map<String, dynamic> json) =>
      SimpleManager(name: json['name']);

  Map<String, dynamic> toJson() => {'name': name};
}
