class OpportunityResponse {
  final int id;
  final String title;
  final String description;
  final String city;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final int seats;

  OpportunityResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.dateFrom,
    required this.dateTo,
    required this.status,
    required this.seats,
  });

  bool get isOpen => status == 'OPEN';

  factory OpportunityResponse.fromJson(Map<String, dynamic> json) {
    return OpportunityResponse(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      dateFrom: DateTime.parse(json['dateFrom'] as String),
      dateTo: DateTime.parse(json['dateTo'] as String),
      status: (json['status'] as String?) ?? 'CLOSED',
      seats: (json['seats'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'city': city,
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'status': status,
        'seats': seats,
      };
}
