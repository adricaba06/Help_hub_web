part of 'organization_list_page_bloc.dart';

@immutable
sealed class OrganizationListPageEvent {}

class LoadManagerOrganizations extends OrganizationListPageEvent {
  final int page;
  final int size;

  LoadManagerOrganizations({this.page = 0, this.size = 5});
}

class RemoveOrganizationFromList extends OrganizationListPageEvent {
  final int organizationId;

  RemoveOrganizationFromList({required this.organizationId});
}
