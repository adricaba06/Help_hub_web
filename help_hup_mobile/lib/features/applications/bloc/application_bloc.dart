import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/application_response.dart';
import '../../../core/services/application_service.dart';

part 'application_event.dart';
part 'application_state.dart';

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  final ApplicationService applicationService;

  ApplicationsBloc(this.applicationService) : super(ApplicationsInitial()) {
    on<ApplicationsRequested>(_onApplicationsRequested);
  }

  Future<void> _onApplicationsRequested(
    ApplicationsRequested event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(ApplicationsLoading(selectedStatus: event.status));

    try {
      final page = await applicationService.getApplicationsByUserId(
        userId: event.userId,
        status: event.status,
        page: event.page,
        size: event.size,
      );

      emit(
        ApplicationsLoaded(
          applications: page.content,
          selectedStatus: event.status,
          totalElements: page.totalElements,
          totalPages: page.totalPages,
          isLastPage: page.last,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ApplicationsError(message: message, selectedStatus: event.status));
    }
  }
}
