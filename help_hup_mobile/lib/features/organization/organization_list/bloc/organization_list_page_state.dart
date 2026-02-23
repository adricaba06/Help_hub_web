part of 'organization_list_page_bloc.dart';

@immutable
sealed class OrganizationListPageState {}

final class OrganizationListPageInitial extends OrganizationListPageState {}

final class OrganizationListPageLoading extends OrganizationListPageState {}

final class OrganizationListPageLoaded extends OrganizationListPageState {
  final OrganizationListResponse organizations;

  OrganizationListPageLoaded({required this.organizations});
}

final class OrganizationListPageError extends OrganizationListPageState {
  final String error;

  OrganizationListPageError({required this.error});
}
