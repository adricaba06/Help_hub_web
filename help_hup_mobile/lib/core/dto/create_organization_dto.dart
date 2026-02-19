class CreateOrganizationDto { // eliminar ??? preguntar a miguel 
  final String name;
  final String city;
  final num logoFieldId;

  CreateOrganizationDto({
    required this.name,
    required this.city,
    required this.logoFieldId,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'city': city, 'logoFieldId': logoFieldId};
  }
}
