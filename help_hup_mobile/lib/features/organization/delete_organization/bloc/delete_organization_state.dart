part of 'delete_organization_bloc.dart';

@immutable
sealed class DeleteOrganizationState {}

final class DeleteOrganizationInitial extends DeleteOrganizationState {}

final class DeleteOrganizationLoading extends DeleteOrganizationState {}

final class DeleteOrganizationLoaded extends DeleteOrganizationState {
  final Organization organization;
  final int organizationId;

  DeleteOrganizationLoaded({
    required this.organization,
    required this.organizationId,
  });
}
final class DeleteOrganizationError extends DeleteOrganizationState {}

