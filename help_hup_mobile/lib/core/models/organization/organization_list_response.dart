import 'package:help_hup_mobile/core/models/organization/organization_response.dart';

class OrganizationListResponse {
  final List<Organization> content;
  final int totalElements;
  final int totalPages;

  OrganizationListResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
  });

  factory OrganizationListResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationListResponse(
      content: List<Organization>.from(
        json['content'].map((x) => Organization.fromJson(x)),
      ),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }
}
