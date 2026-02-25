class ApplicationResponse {
  final int id;
  final int opportunityId;
  final int userId;
  final String motivationText;
  final String status;

  ApplicationResponse({
    required this.id,
    required this.opportunityId,
    required this.userId,
    required this.motivationText,
    required this.status,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      id: (json['id'] as num).toInt(),
      opportunityId: (json['opportunityId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      motivationText: (json['motivationText'] ?? '') as String,
      status: (json['status'] ?? '') as String,
    );
  }
}
