part of 'delete_organization_bloc.dart';

@immutable
sealed class DeleteOrganizationEvent {}

class SubmitDeleteOrganization extends DeleteOrganizationEvent {
  final int organizationId;
  SubmitDeleteOrganization({required this.organizationId});  


}

