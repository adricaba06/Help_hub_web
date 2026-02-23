class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ── Opportunities ──────────────────────────────────────────
  static const String opportunitiesUrl = '$baseUrl/api/opportunities';

  static String opportunityDetailUrl(int id) =>
      '$baseUrl/api/opportunities/$id';

  static String applyToOpportunityUrl(int id) =>
      '$baseUrl/api/opportunities/$id/apply';

  // ── Applications ───────────────────────────────────────────
  static String deleteApplicationUrl(int id) =>
      '$baseUrl/api/applications/$id';
}