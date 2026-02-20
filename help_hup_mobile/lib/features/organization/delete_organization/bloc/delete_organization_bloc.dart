import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'delete_organization_event.dart';
part 'delete_organization_state.dart';

class DeleteOrganizationBloc extends Bloc<DeleteOrganizationEvent, DeleteOrganizationState> {
  final OrganizationService organizationService;
  
  DeleteOrganizationBloc(this.organizationService) : super(DeleteOrganizationInitial()) {
    on<DeleteOrganizationEvent>(_onSubmitDeleteOrganization as EventHandler<DeleteOrganizationEvent, DeleteOrganizationState>);
  }

  Future<void> _onSubmitDeleteOrganization(
    SubmitDeleteOrganization event,
    Emitter<DeleteOrganizationState> emit,
  ) async{
    emit(DeleteOrganizationLoading());
    try {
      final organ = await organizationService.deleteOrganization(event.organizationId);
      emit(DeleteOrganizationLoaded(organization: organ));
    } catch (e) {
      emit(DeleteOrganizationError());
    }
  }
}
