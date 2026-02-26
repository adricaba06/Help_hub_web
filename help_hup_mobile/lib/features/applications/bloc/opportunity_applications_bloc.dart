import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/models/application_response.dart';
import '../../../core/services/application_service.dart';

part 'opportunity_applications_event.dart';
part 'opportunity_applications_state.dart';

class OpportunityApplicationsBloc
    extends Bloc<OpportunityApplicationsEvent, OpportunityApplicationsState> {
  final ApplicationService applicationService;
  final int opportunityId;

  OpportunityApplicationsBloc({
    required this.applicationService,
    required this.opportunityId,
  }) : super(OpportunityApplicationsInitial()) {
    on<LoadOpportunityApplications>(_onLoad);
    on<ChangeApplicationStatus>(_onChangeStatus);
  }

  Future<void> _onLoad(
    LoadOpportunityApplications event,
    Emitter<OpportunityApplicationsState> emit,
  ) async {
    emit(OpportunityApplicationsLoading());
    try {
      final page = await applicationService.getApplicationsByOpportunityId(
        opportunityId: opportunityId,
        page: event.page,
        size: event.size,
      );
      emit(OpportunityApplicationsLoaded(applications: page.content));
    } catch (e) {
      emit(OpportunityApplicationsError(message: e.toString()));
    }
  }

  Future<void> _onChangeStatus(
    ChangeApplicationStatus event,
    Emitter<OpportunityApplicationsState> emit,
  ) async {
    final current = state;
    if (current is! OpportunityApplicationsLoaded) return;

    emit(current.copyWith(isUpdating: true, updatingId: event.applicationId));

    try {
      await applicationService.changeApplicationStatus(
        applicationId: event.applicationId,
        status: event.newStatus,
      );
      
      // Actualizar localmente la aplicación en la lista
      final updatedApps = current.applications.map((app) {
        if (app.id == event.applicationId) {
          // Crear una copia con el nuevo estado
          return ApplicationResponse(
            id: app.id,
            opportunityId: app.opportunityId,
            userId: app.userId,
            userName: app.userName,
            motivationText: app.motivationText,
            status: event.newStatus,
            opportunityTitle: app.opportunityTitle,
            applicationDate: app.applicationDate,
          );
        }
        return app;
      }).toList();
      
      emit(current.copyWith(
        applications: updatedApps,
        isUpdating: false,
        updatingId: null,
      ));
    } catch (e) {
      // keep old list but stop updating on error
      emit(current.copyWith(isUpdating: false, updatingId: null));
    }
  }
}
