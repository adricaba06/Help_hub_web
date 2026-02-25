import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'organization_list_page_event.dart';
part 'organization_list_page_state.dart';

class OrganizationListPageBloc
    extends Bloc<OrganizationListPageEvent, OrganizationListPageState> {
  final OrganizationService organizationService;
  bool _isFetching = false;

  OrganizationListPageBloc(this.organizationService)
    : super(OrganizationListPageInitial()) {
    on<LoadManagerOrganizations>(_onLoadManagerOrganizations);
    on<LoadMoreManagerOrganizations>(_onLoadMoreManagerOrganizations);
    on<RemoveOrganizationFromList>(_onRemoveOrganizationFromList);
  }

  Future<void> _onLoadManagerOrganizations(
    LoadManagerOrganizations event,
    Emitter<OrganizationListPageState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;
    emit(OrganizationListPageLoading());
    try {
      final organizations = await organizationService.getManagersOrganizations(
        page: 0,
        size: event.size,
      );
      emit(
        OrganizationListPageLoaded(
          organizations: organizations.content,
          totalElements: organizations.totalElements,
          totalPages: organizations.totalPages,
          currentPage: 0,
          pageSize: event.size,
        ),
      );
    } catch (e) {
      emit(OrganizationListPageError(error: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onLoadMoreManagerOrganizations(
    LoadMoreManagerOrganizations event,
    Emitter<OrganizationListPageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrganizationListPageLoaded) return;
    if (currentState.isLoadingMore || currentState.hasReachedEnd) return;
    if (_isFetching) return;

    _isFetching = true;
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    try {
      final nextResponse = await organizationService.getManagersOrganizations(
        page: nextPage,
        size: event.size,
      );

      // Avoid duplicates if backend returns overlapping records across pages.
      final merged = <Organization>[
        ...currentState.organizations,
        ...nextResponse.content,
      ];
      final uniqueById = <int, Organization>{};
      for (final org in merged) {
        uniqueById[org.id] = org;
      }

      emit(
        currentState.copyWith(
          organizations: uniqueById.values.toList(),
          totalElements: nextResponse.totalElements,
          totalPages: nextResponse.totalPages,
          currentPage: nextPage,
          isLoadingMore: false,
          pageSize: event.size,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    } finally {
      _isFetching = false;
    }
  }

  void _onRemoveOrganizationFromList(
    RemoveOrganizationFromList event,
    Emitter<OrganizationListPageState> emit,
  ) {
    final currentState = state;
    if (currentState is! OrganizationListPageLoaded) return;

    final updatedContent = currentState.organizations
        .where((organization) => organization.id != event.organizationId)
        .toList();

    emit(
      currentState.copyWith(
        organizations: updatedContent,
        totalElements: currentState.totalElements > 0
            ? currentState.totalElements - 1
            : 0,
      ),
    );
  }
}
