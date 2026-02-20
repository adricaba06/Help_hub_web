import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'organization_list_page_event.dart';
part 'organization_list_page_state.dart';

class OrganizationListPageBloc
    extends Bloc<OrganizationListPageEvent, OrganizationListPageState> {
  final OrganizationService organizationService;

  OrganizationListPageBloc(this.organizationService)
    : super(OrganizationListPageInitial()) {
    on<LoadManagerOrganizations>(_onLoadManagerOrganizations);
    on<RemoveOrganizationFromList>(_onRemoveOrganizationFromList);
  }

  Future<void> _onLoadManagerOrganizations(
    LoadManagerOrganizations event,
    Emitter<OrganizationListPageState> emit,
  ) async {
    emit(OrganizationListPageLoading());
    try {
      final organizations = await organizationService.getManagersOrganizations(
        page: event.page,
        size: event.size,
      );
      emit(OrganizationListPageLoaded(organizations: organizations));
    } catch (e) {
      emit(OrganizationListPageError(error: e.toString()));
    }
  }

  void _onRemoveOrganizationFromList(
    RemoveOrganizationFromList event,
    Emitter<OrganizationListPageState> emit,
  ) {
    final currentState = state;
    if (currentState is! OrganizationListPageLoaded) return;

    final updatedContent = currentState.organizations.content
        .where((organization) => organization.id != event.organizationId)
        .toList();

    emit(
      OrganizationListPageLoaded(
        organizations: OrganizationListResponse(
          content: updatedContent,
          totalElements: updatedContent.length,
          totalPages: currentState.organizations.totalPages,
        ),
      ),
    );
  }
}
