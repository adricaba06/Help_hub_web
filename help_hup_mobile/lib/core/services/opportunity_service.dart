import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/application_response.dart';
import '../models/opportunity_detail_response.dart';
import '../models/opportunity_response.dart';
import 'session_service.dart';
import 'storage_service.dart';

class OpportunityService {
  final StorageService _storage = StorageService();

  Future<List<OpportunityResponse>> searchOpportunities({
    String? query,
    String? city,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }

      if (dateFrom != null) {
        queryParams['dateFrom'] =
            '${dateFrom.year.toString().padLeft(4, '0')}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
      }

      if (dateTo != null) {
        queryParams['dateTo'] =
            '${dateTo.year.toString().padLeft(4, '0')}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
      }

      final uri = Uri.parse(AppConfig.opportunitiesUrl).replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => OpportunityResponse.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexion: $e');
    }
  }

  Future<OpportunityDetailResponse> getOpportunityDetail(int id) async {
    try {
      final token = await _storage.getToken();

      final uri = Uri.parse('${AppConfig.baseUrl}/opportunity/$id');

      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return OpportunityDetailResponse.fromJson(jsonMap);
      } else if (response.statusCode == 401) {
        await _storage.clear();
        SessionService.instance.notifyUnauthorized();
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      } else {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexion: $e');
    }
  }

  Future<ApplicationResponse> applyToOpportunity({
    required int opportunityId,
    required String motivationText,
  }) async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('NO_TOKEN');
    }

    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/opportunities/$opportunityId/apply',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'motivationText': motivationText,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationResponse.fromJson(jsonMap);
    }

    if (response.statusCode == 409) {
      throw Exception('CONFLICT_${response.body}');
    }

    if (response.statusCode == 401) {
      await _storage.clear();
      SessionService.instance.notifyUnauthorized();
      throw Exception('UNAUTHORIZED');
    }

    if (response.statusCode == 403) {
      throw Exception('FORBIDDEN');
    }

    throw Exception('HTTP_${response.statusCode}_${response.body}');
  }
}
