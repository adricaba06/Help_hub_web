import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:help_hup_mobile/core/config/app_config.dart';
import 'package:help_hup_mobile/core/interfaces/organization/create_organization_interface.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/session_service.dart';
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
    final normalized = fieldId.trim();
    if (normalized.isEmpty) return null;
    final lower = normalized.toLowerCase();
    if (lower == 'null' || lower == 'undefined') return null;
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    if (normalized.startsWith('/download/')) {
      return '$_apiBaseUrl$normalized';
    }
    if (normalized.startsWith('download/')) {
      return '$_apiBaseUrl/$normalized';
    }
    return '$_apiBaseUrl/download/$normalized';
  }

  Future<String> uploadImageFile(String filePath) async {
    final authHeaders = await _authHeaders();

    final candidates = <String>[
      '$_apiBaseUrl/upload',
      '$_apiBaseUrl/api/upload',
      '$_apiBaseUrl/upload/files',
      '$_apiBaseUrl/api/upload/files',
    ];

    String? lastError;

    for (final url in candidates) {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(authHeaders);
      final fileField = url.endsWith('/upload/files') ? 'files' : 'file';
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

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

      if (response.statusCode == 401) {
        await _storageService.clear();
        SessionService.instance.notifyUnauthorized();
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
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
    final headers = await _jsonHeaders();
    final payload = jsonEncode(org.toJson());
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/organizations'),
      headers: headers,
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Organization.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      await _storageService.clear();
      SessionService.instance.notifyUnauthorized();
      throw Exception('Sesion expirada. Inicia sesion nuevamente.');
    }

    throw Exception(
      'Error al crear la organizacion (HTTP ${response.statusCode}). '
      'Body: ${response.body}. Payload enviado: $payload',
    );
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
    } else if (response.statusCode == 401) {
      await _storageService.clear();
      SessionService.instance.notifyUnauthorized();
      throw Exception('Sesion expirada. Inicia sesion nuevamente.');
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
    } else if (response.statusCode == 401) {
      await _storageService.clear();
      SessionService.instance.notifyUnauthorized();
      throw Exception('Sesion expirada. Inicia sesion nuevamente.');
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
    } else if (response.statusCode == 401) {
      await _storageService.clear();
      SessionService.instance.notifyUnauthorized();
      throw Exception('Sesion expirada. Inicia sesion nuevamente.');
    } else {
      throw Exception('Error al obtener el detalle de la organizacion');
    }
  }
}

extension on OrganizationService {
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      await _storageService.clear();
      SessionService.instance.notifyUnauthorized();
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
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic>) {
        final dynamic value = first['id'] ?? first['fieldId'] ?? first['uri'];
        return _normalizeUploadIdentifier(value);
      }
    }
    if (decoded is int) return decoded.toString();
    if (decoded is num) return decoded.toInt().toString();
    if (decoded is String) return decoded;
    if (decoded is Map<String, dynamic>) {
      final dynamic value = decoded['id'] ?? decoded['fieldId'] ?? decoded['uri'];
      return _normalizeUploadIdentifier(value);
    }
  } catch (_) {
    // Some backends return plain text without JSON quotes.
    return trimmed;
  }

  return null;
}

String? _normalizeUploadIdentifier(dynamic value) {
  if (value == null) return null;
  if (value is int) return value.toString();
  if (value is num) return value.toInt().toString();
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final downloadIndex = uri.pathSegments.indexOf('download');
      if (downloadIndex != -1 && downloadIndex + 1 < uri.pathSegments.length) {
        return uri.pathSegments[downloadIndex + 1];
      }
    }
    return normalized;
  }
  return null;
}
