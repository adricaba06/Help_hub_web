part of 'delete_organization_bloc.dart';

@immutable
sealed class DeleteOrganizationState {}

final class DeleteOrganizationInitial extends DeleteOrganizationState {}

final class DeleteOrganizationLoading extends DeleteOrganizationState {}

final class DeleteOrganizationLoaded extends DeleteOrganizationState {
  final Organization organization;

  DeleteOrganizationLoaded({required this.organization});
}
final class DeleteOrganizationError extends DeleteOrganizationState {}

