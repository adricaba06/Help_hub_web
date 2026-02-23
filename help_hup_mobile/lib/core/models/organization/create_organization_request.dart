class CreateOrganizationRequest {
  final String name;
  final String city;
  final String logoFieldId;
  final String coverFieldId;
  final String description;

  CreateOrganizationRequest({
    required this.name,
    required this.city,
    required this.logoFieldId,
    required this.coverFieldId,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'logoFieldId': logoFieldId,
        'coverFieldId': coverFieldId,
        'description': description,
      };
}
