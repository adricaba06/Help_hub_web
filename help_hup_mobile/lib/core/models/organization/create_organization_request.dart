class CreateOrganizationRequest {
  final String name;
  final String city;
  final int logoFieldId;

  CreateOrganizationRequest({
    required this.name,
    required this.city,
    required this.logoFieldId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'logoFieldId': logoFieldId,
      };
}
