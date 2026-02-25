import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/opportunity_response.dart';
import 'storage_service.dart';

class FavoriteOpportunityService {
  final StorageService _storage = StorageService();

  Future<List<OpportunityResponse>> getMyFavorites({
    bool useFallback = true,
  }) async {
    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
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

        if (useFallback) {
          return _loadDefaultFavoritesForLoggedUser(token);
        }

        return [];
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado. Inicia sesion de nuevo.');
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

  Future<Set<int>> getMyFavoriteIds() async {
    final favorites = await getMyFavorites(useFallback: false);
    return favorites.map((opportunity) => opportunity.id).toSet();
  }

  Future<void> addFavorite(int opportunityId) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No autorizado. Inicia sesion de nuevo.');
    }

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/favorites/$opportunityId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 409) {
      // Treat conflicts as success so the operation is idempotent:
      // if it is already favorite, desired state is already achieved.
      return;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('No autorizado. Inicia sesion de nuevo.');
    }

    throw Exception(
      'Error al marcar favorito (${response.statusCode}): ${response.body}',
    );
  }

  Future<void> removeFavorite(int opportunityId) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No autorizado. Inicia sesion de nuevo.');
    }

    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/favorites/$opportunityId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 404) {
      // Treat not-found as success so the operation is idempotent:
      // if it is already removed, desired state is already achieved.
      return;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('No autorizado. Inicia sesion de nuevo.');
    }

    throw Exception(
      'Error al quitar favorito (${response.statusCode}): ${response.body}',
    );
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
