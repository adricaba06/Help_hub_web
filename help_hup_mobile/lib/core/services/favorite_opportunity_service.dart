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
      if (token == null || token.isEmpty) {
        throw Exception('No autorizado. Inicia sesión de nuevo.');
      }

      final response = await http.get(
        Uri.parse(AppConfig.favoritesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final favorites = jsonList
            .map((json) => OpportunityResponse.fromJson(json))
            .toList();

        if (favorites.isNotEmpty) {
          return favorites;
        }

        return _loadDefaultFavoritesForLoggedUser(token);
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

  Future<List<OpportunityResponse>> _loadDefaultFavoritesForLoggedUser(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(AppConfig.opportunitiesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    final opportunities = jsonList
        .map((json) => OpportunityResponse.fromJson(json))
        .toList();

    if (opportunities.isEmpty) {
      return [];
    }

    final user = await _storage.getUser();
    final role = (user?.role ?? 'USER').toUpperCase();

    if (role == 'MANAGER') {
      return [];
    }

    final int amount = role == 'ADMIN' ? 1 : 3;
    return opportunities.take(amount).toList();
  }
}
