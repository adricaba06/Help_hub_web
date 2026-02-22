class CreateOrganizationRequest {
  final String name;
  final String city;
  final String description;
  final String? logoFieldId;
  final String? coverFieldId;

  CreateOrganizationRequest({
    required this.name,
    required this.city,
    required this.description,
    this.logoFieldId,
    this.coverFieldId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'description': description,
        'logoFieldId': logoFieldId,
        'coverFieldId': coverFieldId,
      };
}
