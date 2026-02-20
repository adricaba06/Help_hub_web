import 'dart:convert';

import 'package:help_hup_mobile/core/interfaces/organization/create_organization_interface.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:http/http.dart' as http;
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:flutter/foundation.dart';

class OrganizationService implements CreateOrganizationInterface {
  String get _apiBaseUrl {
    //corregido??
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  @override
  Future<Organization> createOrganization(CreateOrganizationRequest org) async {
    try {
      const String testToken =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiaWF0IjoxNzcxNTkyMjgyLCJleHAiOjE3NzE2Nzg2ODJ9.s0JhhNLbwH-aQGvBBwG79f-zyY-M1-G9R8t2ixkByfw0xaRNOSL_yKWTFgaYHKT1c3EvrXt31gt2o8Cg7NbqkA';

      final response = await http.post(
        Uri.parse("$_apiBaseUrl/organizations"),
        headers: {
          'Authorization': 'Bearer $testToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(org.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Organization.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la organización: ${response.body}');
      }
    } catch (e) {
      throw Exception(
        'Error en la petición POST: $e',
      ); // como en java cuando hacemos e.getMessage()
    }
  }

  @override
  Future<OrganizationListResponse> getManagersOrganizations({
    int page = 0,
    int size = 5,
  }) async {
    const String testToken =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiaWF0IjoxNzcxNTkyMjgyLCJleHAiOjE3NzE2Nzg2ODJ9.s0JhhNLbwH-aQGvBBwG79f-zyY-M1-G9R8t2ixkByfw0xaRNOSL_yKWTFgaYHKT1c3EvrXt31gt2o8Cg7NbqkA'; // token real

    final uri = Uri.parse('$_apiBaseUrl?page=$page&size=$size');
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/organizations?page=0&size=5'),
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OrganizationListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener organizaciones del manager');
    }
  }
  
  @override
  Future<Organization> deleteOrganization(int id) async {

    const String testToken =  'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiaWF0IjoxNzcxNTkyMjgyLCJleHAiOjE3NzE2Nzg2ODJ9.s0JhhNLbwH-aQGvBBwG79f-zyY-M1-G9R8t2ixkByfw0xaRNOSL_yKWTFgaYHKT1c3EvrXt31gt2o8Cg7NbqkA';

    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/organizations/$id'),
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
    );

  if (response.statusCode >= 200 && response.statusCode < 300) {
      return Organization.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al borrar la organización');
    }
    
  }
}
