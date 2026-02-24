import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/opportunity_response.dart';
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
import 'session_service.dart';
import 'storage_service.dart';
>>>>>>> origin/main
>>>>>>> 30cb3fff35d7203e6d288c0b04b7957cf05672b8

class OpportunityService {
  Future<List<OpportunityResponse>> searchOpportunities({
    String? query,
    String? city,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
<<<<<<< HEAD
=======
<<<<<<< HEAD
      // Construir queryParameters dinámicamente
=======
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        await _storage.clear();
        SessionService.instance.notifyUnauthorized();
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

>>>>>>> origin/main
>>>>>>> 30cb3fff35d7203e6d288c0b04b7957cf05672b8
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
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
          'Authorization': 'Bearer $token',
>>>>>>> origin/main
>>>>>>> 30cb3fff35d7203e6d288c0b04b7957cf05672b8
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
}
