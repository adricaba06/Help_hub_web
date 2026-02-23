part of 'organization_list_page_bloc.dart';

@immutable
sealed class OrganizationListPageEvent {}

class LoadManagerOrganizations extends OrganizationListPageEvent {
  final int size;

  LoadManagerOrganizations({this.size = 5});
}

class LoadMoreManagerOrganizations extends OrganizationListPageEvent {
  final int size;

  LoadMoreManagerOrganizations({this.size = 5});
}

class RemoveOrganizationFromList extends OrganizationListPageEvent {
  final int organizationId;

  RemoveOrganizationFromList({required this.organizationId});
}
