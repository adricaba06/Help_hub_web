import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/opportunity_response.dart';
import 'storage_service.dart';

class OpportunityService {
  final StorageService _storage = StorageService();

  Future<List<OpportunityResponse>> searchOpportunities(String query) async {
    try {
      final token = await _storage.getToken();
      
      final uri = Uri.parse(AppConfig.opportunitiesUrl).replace(
        queryParameters: query.isEmpty ? null : {'q': query},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => OpportunityResponse.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 404) {
        return [];
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
