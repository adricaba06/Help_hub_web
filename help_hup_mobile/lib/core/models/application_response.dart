class ApplicationResponse {
  final int id;
  final String motivationText;
  final String status;
  final String opportunityTitle;
  final DateTime? applicationDate;

  ApplicationResponse({
    required this.id,
    required this.motivationText,
    required this.status,
    required this.opportunityTitle,
    required this.applicationDate,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    final rawDate = json['applicationDate']?.toString();

    return ApplicationResponse(
      id: json['id'] as int,
      motivationText: json['motivationText']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      opportunityTitle: json['opportunityTitle']?.toString() ?? '',
      applicationDate: rawDate == null || rawDate.isEmpty
          ? null
          : DateTime.tryParse(rawDate),
    );
  }
}
