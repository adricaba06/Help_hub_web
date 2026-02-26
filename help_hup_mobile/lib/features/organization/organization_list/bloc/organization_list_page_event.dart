part of 'organization_list_page_bloc.dart';

@immutable
sealed class OrganizationListPageEvent {}

class LoadOrganizations extends OrganizationListPageEvent {
  final int size;
  final bool fetchAll;
  final String? name;
  final String? city;

  LoadOrganizations({
    this.size = 5,
    this.fetchAll = false,
    this.name,
    this.city,
  });
}

class LoadMoreOrganizations extends OrganizationListPageEvent {
  final int size;

  LoadMoreOrganizations({this.size = 5});
}

class RemoveOrganizationFromList extends OrganizationListPageEvent {
  final int organizationId;

  RemoveOrganizationFromList({required this.organizationId});
}
