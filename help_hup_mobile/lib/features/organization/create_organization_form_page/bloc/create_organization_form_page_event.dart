part of 'create_organization_form_page_bloc.dart';

@immutable
sealed  class CreateOrganizationFormPageEvent {}

class SubmitCreateOrganization extends CreateOrganizationFormPageEvent {
  final CreateOrganizationRequest organizationRequest;

  SubmitCreateOrganization({required this.organizationRequest});
}
