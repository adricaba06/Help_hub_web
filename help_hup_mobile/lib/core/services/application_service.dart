import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApplicationService {
  final _storage = StorageService();

  /// Obtiene el token e invoca POST /api/opportunities/{id}/apply.
  /// Uso recomendado desde el modal (no necesita recibir el token).
  Future<void> apply(int opportunityId, String motivation) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión caducada. Inicia sesión otra vez.');
    }
    await applyToOpportunity(
      opportunityId: opportunityId,
      token: token,
      motivationText: motivation,
    );
  }

  /// Versión explícita (token como parámetro) — mantenida por compatibilidad.
  Future<void> applyToOpportunity({
    required int opportunityId,
    required String token,
    required String motivationText,
  }) async {
    final url = Uri.parse(AppConfig.applyToOpportunityUrl(opportunityId));

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'motivationText': motivationText}),
    );

    if (res.statusCode == 201) return;

    if (res.statusCode == 401) throw Exception('Sesión caducada.');
    if (res.statusCode == 403) throw Exception('Sin permisos.');
    if (res.statusCode == 404) throw Exception('Oportunidad no encontrada.');
    if (res.statusCode == 409) throw Exception('Ya has aplicado o no cumples condiciones.');

    throw Exception('Error ${res.statusCode}');
  }

  /// DELETE /api/applications/{id}
  Future<void> deleteApplication({
    required int applicationId,
    required String token,
  }) async {
    final url = Uri.parse(AppConfig.deleteApplicationUrl(applicationId));

    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 204 || res.statusCode == 200) return;
    if (res.statusCode == 401) throw Exception('Sesión caducada.');
    if (res.statusCode == 403) throw Exception('No permitido.');
    if (res.statusCode == 404) throw Exception('Solicitud no encontrada.');

    throw Exception('Error inesperado (${res.statusCode}).');
  }
}
