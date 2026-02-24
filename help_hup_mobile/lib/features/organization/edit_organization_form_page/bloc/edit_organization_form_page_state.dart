part of 'edit_organization_form_page_bloc.dart';

@immutable
sealed class EditOrganizationFormPageState {}

final class EditOrganizationFormPageInitial
    extends EditOrganizationFormPageState {}

final class EditOrganizationFormPageLoading
    extends EditOrganizationFormPageState {}

final class EditOrganizationFormPageLoaded
    extends EditOrganizationFormPageState {
  final Organization organization;

  EditOrganizationFormPageLoaded({required this.organization});
}

final class EditOrganizationFormPageError
    extends EditOrganizationFormPageState {
  final String error;

  EditOrganizationFormPageError({required this.error});
}
