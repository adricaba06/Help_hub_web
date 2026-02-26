part of 'opportunity_applications_bloc.dart';

@immutable
abstract class OpportunityApplicationsState {}

class OpportunityApplicationsInitial extends OpportunityApplicationsState {}

class OpportunityApplicationsLoading extends OpportunityApplicationsState {}

class OpportunityApplicationsLoaded extends OpportunityApplicationsState {
  final List<ApplicationResponse> applications;
  final bool isUpdating;
  final int? updatingId;

  OpportunityApplicationsLoaded({
    required this.applications,
    this.isUpdating = false,
    this.updatingId,
  });

  OpportunityApplicationsLoaded copyWith({
    List<ApplicationResponse>? applications,
    bool? isUpdating,
    int? updatingId,
  }) {
    return OpportunityApplicationsLoaded(
      applications: applications ?? this.applications,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingId: updatingId ?? this.updatingId,
    );
  }
}

class OpportunityApplicationsError extends OpportunityApplicationsState {
  final String message;
  OpportunityApplicationsError({required this.message});
}
