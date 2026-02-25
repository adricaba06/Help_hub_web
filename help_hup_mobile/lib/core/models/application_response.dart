class ApplicationResponse {
  final int id;
  final int opportunityId;
  final int userId;
  final String motivationText;
  final String status;
  final String opportunityTitle;
  final DateTime? applicationDate;

  ApplicationResponse({
    required this.id,
    required this.opportunityId,
    required this.userId,
    required this.motivationText,
    required this.status,
    required this.opportunityTitle,
    required this.applicationDate,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    final rawDate = json['applicationDate']?.toString();

    return ApplicationResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      opportunityId: (json['opportunityId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      motivationText: json['motivationText']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      opportunityTitle: json['opportunityTitle']?.toString() ?? '',
      applicationDate: rawDate == null || rawDate.isEmpty
          ? null
          : DateTime.tryParse(rawDate),
    );
  }
}
