import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/opportunity_response.dart';
import 'storage_service.dart';

class FavoriteOpportunityService {
  final StorageService _storage = StorageService();

  Future<List<OpportunityResponse>> getMyFavorites() async {
    try {
      final token = await _storage.getToken();

      final response = await http.get(
        Uri.parse(AppConfig.favoritesUrl),
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
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado. Inicia sesión de nuevo.');
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
