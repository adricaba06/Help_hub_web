import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/application_page_response.dart';
import '../models/application_response.dart';
import 'storage_service.dart';

class ApplicationService {
  final StorageService _storageService = StorageService();

  Future<ApplicationPageResponse> getApplicationsByUserId({
    required int userId,
    String? status,
    int page = 0,
    int size = 8,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
      }

      final queryParameters = <String, String>{
        'page': '$page',
        'size': '$size',
      };

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      final uri = Uri.parse('${AppConfig.applicationsUrl}/users/$userId')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApplicationPageResponse.fromJson(json);
      }

      if (response.statusCode == 404) {
        return ApplicationPageResponse.empty();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
      }

      throw Exception(
        'Error del servidor (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexion: $e');
    }
  }

  Future<ApplicationPageResponse> getApplicationsByOpportunityId({
    required int opportunityId,
    int page = 0,
    int size = 8,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
      }

      final queryParameters = <String, String>{
        'page': '$page',
        'size': '$size',
      };

      final uri = Uri.parse('${AppConfig.applicationsUrl}/opportunity/$opportunityId')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApplicationPageResponse.fromJson(json);
      }

      if (response.statusCode == 404) {
        return ApplicationPageResponse.empty();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
      }

      throw Exception(
        'Error del servidor (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexion: $e');
    }
  }

  /// Manager endpoint: update the status of an application
  Future<ApplicationResponse> changeApplicationStatus({
    required int applicationId,
    required String status,
  }) async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('NO_TOKEN');
    }

    final url = Uri.parse('${AppConfig.applicationsUrl}/$applicationId/status');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationResponse.fromJson(jsonMap);
    }

    if (response.statusCode == 400) {
      throw Exception('BAD_REQUEST_${response.body}');
    }

    if (response.statusCode == 401) {
      await _storageService.clear();
      throw Exception('UNAUTHORIZED');
    }

    if (response.statusCode == 403) {
      throw Exception('FORBIDDEN');
    }

    if (response.statusCode == 404) {
      throw Exception('NOT_FOUND');
    }

    throw Exception('HTTP_${response.statusCode}_${response.body}');
  }
}
