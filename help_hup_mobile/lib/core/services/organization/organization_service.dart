import 'dart:convert';

import 'package:help_hup_mobile/core/interfaces/organization/create_organization_interface.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:http/http.dart' as http;
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';

class OrganizationService implements CreateOrganizationInterface {
  final String _apiBaseUrl = 'http://localhost:8080';

  @override
  Future<Organization> createOrganization(CreateOrganizationRequest org) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiBaseUrl/organizations"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(org.toJson()), 
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Organization.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la organización: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la petición POST: $e'); // como en java cuando hacemos e.getMessage()
    }
  }
}