import 'application_response.dart';

class ApplicationPageResponse {
  final List<ApplicationResponse> content;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  ApplicationPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory ApplicationPageResponse.fromJson(Map<String, dynamic> json) {
    final rawContent = (json['content'] as List<dynamic>? ?? <dynamic>[]);

    return ApplicationPageResponse(
      content: rawContent
          .map((item) =>
              ApplicationResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? rawContent.isEmpty,
    );
  }

  factory ApplicationPageResponse.empty() {
    return ApplicationPageResponse(
      content: const [],
      totalElements: 0,
      totalPages: 0,
      first: true,
      last: true,
      empty: true,
    );
  }
}
