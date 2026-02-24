class OpportunityResponse {
  final int id;
  final String title;
  final String city;
  final DateTime dateFrom;
  final DateTime dateTo;
  final int seats;
  final String status;

  OpportunityResponse({
    required this.id,
    required this.title,
    required this.city,
    required this.dateFrom,
    required this.dateTo,
    required this.seats,
    required this.status,
  });

  factory OpportunityResponse.fromJson(Map<String, dynamic> json) {
    return OpportunityResponse(
      id: json['id'],
      title: json['title'],
      city: json['city'],
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      seats: json['seats'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
      'seats': seats,
      'status': status,
    };
  }

  bool get isOpen => status == 'OPEN';
}
