class Opportunity {
  final int id;
  final String title;
  final String? city;
  final String? organization;
  final String? imageUrl;
  final String? status;
  final String? dateFrom;
  final String? dateTo;
  final int? seats;

  const Opportunity({
    required this.id,
    required this.title,
    this.city,
    this.organization,
    this.imageUrl,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.seats,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as int,
      title: json['title'] as String,
      city: json['city'] as String?,
      organization: json['organization'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String?,
      dateFrom: json['dateFrom'] as String?,
      dateTo: json['dateTo'] as String?,
      seats: json['seats'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (city != null) 'city': city,
        if (organization != null) 'organization': organization,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (status != null) 'status': status,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
        if (seats != null) 'seats': seats,
      };
}
