part of 'organization_opportunities_bloc.dart';

@immutable
sealed class OrganizationOpportunitiesEvent {
  const OrganizationOpportunitiesEvent();
}

final class LoadOrganizationOpportunities
    extends OrganizationOpportunitiesEvent {
  const LoadOrganizationOpportunities();
}

final class LoadMoreOrganizationOpportunities
    extends OrganizationOpportunitiesEvent {
  const LoadMoreOrganizationOpportunities();
}

final class RefreshOrganizationOpportunities
    extends OrganizationOpportunitiesEvent {
  const RefreshOrganizationOpportunities();
}
