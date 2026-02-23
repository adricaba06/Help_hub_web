import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'create_organization_form_page_event.dart';
part 'create_organization_form_page_state.dart';

class CreateOrganizationFormPageBloc
    extends
        Bloc<CreateOrganizationFormPageEvent, CreateOrganizationFormPageState> {
  final OrganizationService organizationService;

  CreateOrganizationFormPageBloc(this.organizationService)
    : super(CreateOrganizationFormPageInitial()) {
    on<SubmitCreateOrganization>(_onSubmitCreateOrganization);
  }

  Future<void> _onSubmitCreateOrganization(
    SubmitCreateOrganization event,
    Emitter<CreateOrganizationFormPageState> emit,
  ) async {
    emit(CreateOrganizationFormPageLoading());
    try {
      final organ = await organizationService.createOrganization(
        event.organizationRequest,
      );
      emit(CreateOrganizationFormPageLoaded(organization: organ));
    } catch (e) {
      emit(CreateOrganizationFormPageError(error: e.toString()));
    }
  }
}
