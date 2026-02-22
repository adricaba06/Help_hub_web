import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:help_hup_mobile/core/config/app_config.dart';
import 'package:help_hup_mobile/core/interfaces/organization/create_organization_interface.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/storage_service.dart';
import 'package:http/http.dart' as http;

class OrganizationService implements CreateOrganizationInterface {
  String get _apiBaseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AppConfig.baseUrl;
    }
    return 'http://localhost:8080';
  }

  final StorageService _storageService = StorageService();

  String? buildImageUrl(String? fieldId) {
    if (fieldId == null) return null;
    return '$_apiBaseUrl/images/$fieldId';
  }

  Future<String> uploadImageFile(String filePath) async {
    final authHeaders = await _authHeaders();

    final candidates = <String>[
      '$_apiBaseUrl/images/upload',
      '$_apiBaseUrl/api/images/upload',
    ];

    String? lastError;

    for (final url in candidates) {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(authHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final parsed = _extractFieldId(body);
        if (parsed == null) {
          throw Exception(
            'No se pudo leer fieldId/id (string o numero) de la respuesta: $body',
          );
        }
        return parsed;
      }

      lastError =
          'Upload fallo en $url -> ${response.statusCode} ${body.trim()}';

      if (response.statusCode != 404) {
        break;
      }
    }

    throw Exception(lastError ?? 'Error desconocido al subir imagen.');
  }

  @override
  Future<Organization> createOrganization(CreateOrganizationRequest org) async {
    try {
      final headers = await _jsonHeaders();
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/organizations'),
        headers: headers,
        body: jsonEncode(org.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Organization.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la organizacion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la peticion POST: $e');
    }
  }

  @override
  Future<OrganizationListResponse> getManagersOrganizations({
    int page = 0,
    int size = 5,
  }) async {
    final headers = await _jsonHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/organizations?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OrganizationListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener organizaciones del manager');
    }
  }

  @override
  Future<Organization> deleteOrganization(int id) async {
    final headers = await _jsonHeaders();
    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/organizations/$id'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Organization.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al borrar la organizacion');
    }
  }

  @override
  Future<Organization> getOrganizationById(int id) async {
    final headers = await _jsonHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/organizations/$id'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Organization.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener el detalle de la organizacion');
    }
  }
}

extension on OrganizationService {
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay token de sesion. Inicia sesion de nuevo.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<Map<String, String>> _jsonHeaders() async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    return headers;
  }
}

String? _extractFieldId(String body) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return null;

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is int) return decoded.toString();
    if (decoded is num) return decoded.toInt().toString();
    if (decoded is String) return decoded;
    if (decoded is Map<String, dynamic>) {
      final dynamic value = decoded['fieldId'] ?? decoded['id'];
      if (value is int) return value.toString();
      if (value is num) return value.toInt().toString();
      if (value is String) return value;
    }
  } catch (_) {
    // Some backends return plain text without JSON quotes.
    return trimmed;
  }

  return null;
}
