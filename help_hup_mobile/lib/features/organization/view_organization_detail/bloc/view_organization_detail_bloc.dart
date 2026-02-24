import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'view_organization_detail_event.dart';
part 'view_organization_detail_state.dart';

class ViewOrganizationDetailBloc
    extends Bloc<ViewOrganizationDetailEvent, ViewOrganizationDetailState> {
  final OrganizationService organizationService;

  ViewOrganizationDetailBloc(this.organizationService)
    : super(ViewOrganizationDetailInitial()) {
    on<LoadOrganizationDetail>(_onLoadOrganizationDetail);
  }

  Future<void> _onLoadOrganizationDetail(
    LoadOrganizationDetail event,
    Emitter<ViewOrganizationDetailState> emit,
  ) async {
    emit(ViewOrganizationDetailLoading());
    try {
      final organization = await organizationService.getOrganizationById(
        event.organizationId,
      );
      emit(ViewOrganizationDetailLoaded(organization: organization));
    } catch (e) {
      emit(ViewOrganizationDetailError(error: e.toString()));
    }
  }
}
