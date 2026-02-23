part of 'view_organization_detail_bloc.dart';

@immutable
sealed class ViewOrganizationDetailEvent {}

class LoadOrganizationDetail extends ViewOrganizationDetailEvent {
  final int organizationId;

  LoadOrganizationDetail({required this.organizationId});
}
