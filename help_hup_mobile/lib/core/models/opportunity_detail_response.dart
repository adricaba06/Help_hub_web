import 'opportunity_response.dart';

class OpportunityDetailResponse {
  final OpportunityResponse opportunity;
  final int acceptedCount;
  final int seatsLeft;
  final bool canApply;
  final bool hasApplied;
  final int? myApplicationId;
  final bool canEdit;
  final bool canDelete;

  OpportunityDetailResponse({
    required this.opportunity,
    required this.acceptedCount,
    required this.seatsLeft,
    required this.canApply,
    required this.hasApplied,
    required this.myApplicationId,
    required this.canEdit,
    required this.canDelete,
  });

  factory OpportunityDetailResponse.fromJson(Map<String, dynamic> json) {
    return OpportunityDetailResponse(
      opportunity: OpportunityResponse.fromJson(json['opportunity']),
      acceptedCount: (json['acceptedCount'] as num).toInt(),
      seatsLeft: (json['seatsLeft'] as num).toInt(),
      canApply: json['canApply'] as bool,
      hasApplied: json['hasApplied'] as bool,
      myApplicationId: json['myApplicationId'] == null
          ? null
          : (json['myApplicationId'] as num).toInt(),
      canEdit: json['canEdit'] as bool,
      canDelete: json['canDelete'] as bool,
    );
  }
}
