import 'opportunity_response.dart';

class OpportunityPageResponse {
  final List<OpportunityResponse> content;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  OpportunityPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory OpportunityPageResponse.fromJson(Map<String, dynamic> json) {
    final rawContent = (json['content'] as List<dynamic>? ?? <dynamic>[]);

    return OpportunityPageResponse(
      content: rawContent
          .map((item) => OpportunityResponse.fromJson(item))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      empty: json['empty'] ?? rawContent.isEmpty,
    );
  }
}
