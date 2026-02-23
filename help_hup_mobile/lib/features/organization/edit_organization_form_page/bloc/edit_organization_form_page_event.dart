part of 'edit_organization_form_page_bloc.dart';

@immutable
sealed class EditOrganizationFormPageEvent {}

class SubmitEditOrganization extends EditOrganizationFormPageEvent {
  final int organizationId;
  final EditOrganizationRequest organizationRequest;

  SubmitEditOrganization({
    required this.organizationId,
    required this.organizationRequest,
  });
}
