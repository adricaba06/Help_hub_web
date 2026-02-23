part of 'view_organization_detail_bloc.dart';

@immutable
sealed class ViewOrganizationDetailState {}

final class ViewOrganizationDetailInitial
    extends ViewOrganizationDetailState {}

final class ViewOrganizationDetailLoading
    extends ViewOrganizationDetailState {}

final class ViewOrganizationDetailLoaded extends ViewOrganizationDetailState {
  final Organization organization;

  ViewOrganizationDetailLoaded({required this.organization});
}

final class ViewOrganizationDetailError extends ViewOrganizationDetailState {
  final String error;

  ViewOrganizationDetailError({required this.error});
}
