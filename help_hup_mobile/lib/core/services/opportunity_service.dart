import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/opportunity_response.dart';
import '../models/opportunity_detail_response.dart';
import 'storage_service.dart';

class OpportunityService {
  final StorageService _storage = StorageService();

  // Devuelve el listado de oportunidades (con búsqueda opcional)
  Future<List<OpportunityResponse>> searchOpportunities({String? query}) async {
    try {
      final token = await _storage.getToken();

      final uri = query != null && query.isNotEmpty
          ? Uri.parse(AppConfig.opportunitiesUrl)
              .replace(queryParameters: {'q': query})
          : Uri.parse(AppConfig.opportunitiesUrl);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list
            .map((e) => OpportunityResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(
            'Error del servidor (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }

  // Devuelve el detalle de una oportunidad por id
  Future<OpportunityDetailResponse> getOpportunityDetail(int id) async {
    try {
      final token = await _storage.getToken();

      final uri = Uri.parse(AppConfig.opportunityDetailUrl(id));

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return OpportunityDetailResponse.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Oportunidad no encontrada.');
      } else {
        throw Exception(
            'Error del servidor (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: $e');
    }
  }
}
