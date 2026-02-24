part of 'create_organization_form_page_bloc.dart';

@immutable
sealed class CreateOrganizationFormPageState {}

final class CreateOrganizationFormPageInitial
    extends CreateOrganizationFormPageState {}

final class CreateOrganizationFormPageLoading
    extends CreateOrganizationFormPageState {}

final class CreateOrganizationFormPageLoaded
    extends CreateOrganizationFormPageState {
  final Organization organization;
  CreateOrganizationFormPageLoaded({required this.organization});
}

final class CreateOrganizationFormPageError
    extends CreateOrganizationFormPageState {
  final String error;
  CreateOrganizationFormPageError({required this.error});
}
