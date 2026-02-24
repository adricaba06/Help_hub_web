import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/edit_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'edit_organization_form_page_event.dart';
part 'edit_organization_form_page_state.dart';

class EditOrganizationFormPageBloc
    extends Bloc<EditOrganizationFormPageEvent, EditOrganizationFormPageState> {
  final OrganizationService organizationService;

  EditOrganizationFormPageBloc(this.organizationService)
    : super(EditOrganizationFormPageInitial()) {
    on<SubmitEditOrganization>(_onSubmitEditOrganization);
  }

  Future<void> _onSubmitEditOrganization(
    SubmitEditOrganization event,
    Emitter<EditOrganizationFormPageState> emit,
  ) async {
    emit(EditOrganizationFormPageLoading());
    try {
      final organization = await organizationService.editOrganization(
        event.organizationRequest,
        event.organizationId,
      );
      emit(EditOrganizationFormPageLoaded(organization: organization));
    } catch (e) {
      emit(EditOrganizationFormPageError(error: e.toString()));
    }
  }
}
