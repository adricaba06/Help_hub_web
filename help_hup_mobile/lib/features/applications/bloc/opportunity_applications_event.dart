part of 'opportunity_applications_bloc.dart';

@immutable
abstract class OpportunityApplicationsEvent {}

class LoadOpportunityApplications extends OpportunityApplicationsEvent {
  final int page;
  final int size;

  LoadOpportunityApplications({
    this.page = 0,
    this.size = 8,
  });
}

class ChangeApplicationStatus extends OpportunityApplicationsEvent {
  final int applicationId;
  final String newStatus;

  ChangeApplicationStatus({
    required this.applicationId,
    required this.newStatus,
  });
}
