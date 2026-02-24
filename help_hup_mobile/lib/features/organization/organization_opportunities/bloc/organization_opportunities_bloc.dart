import 'package:bloc/bloc.dart';
import 'package:help_hup_mobile/core/models/opportunity_filter.dart';
import 'package:help_hup_mobile/core/models/opportunity_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:meta/meta.dart';

part 'organization_opportunities_event.dart';
part 'organization_opportunities_state.dart';

class OrganizationOpportunitiesBloc
    extends
        Bloc<OrganizationOpportunitiesEvent, OrganizationOpportunitiesState> {
  final OrganizationService organizationService;
  final int organizationId;
  final int pageSize;
  bool _isFetching = false;
  OpportunityFilter _currentFilter = const OpportunityFilter();

  OrganizationOpportunitiesBloc({
    required this.organizationService,
    required this.organizationId,
    this.pageSize = 8,
  }) : super(OrganizationOpportunitiesInitial()) {
    on<LoadOrganizationOpportunities>(_onLoad);
    on<LoadMoreOrganizationOpportunities>(_onLoadMore);
    on<RefreshOrganizationOpportunities>(_onRefresh);
    on<ApplyOrganizationOpportunitiesFilter>(_onApplyFilter);
  }

  Future<void> _onLoad(
    LoadOrganizationOpportunities event,
    Emitter<OrganizationOpportunitiesState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;
    emit(OrganizationOpportunitiesLoading());

    try {
      final response = await organizationService.getOpportunitiesByOrganizationId(
        organizationId: organizationId,
        page: 0,
        size: pageSize,
        filter: _currentFilter,
      );

      emit(
        OrganizationOpportunitiesLoaded(
          opportunities: response.content,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: 0,
          pageSize: pageSize,
          filter: _currentFilter,
        ),
      );
    } catch (e) {
      emit(OrganizationOpportunitiesError(error: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh(
    RefreshOrganizationOpportunities event,
    Emitter<OrganizationOpportunitiesState> emit,
  ) async {
    await _onLoad(const LoadOrganizationOpportunities(), emit);
  }

  Future<void> _onLoadMore(
    LoadMoreOrganizationOpportunities event,
    Emitter<OrganizationOpportunitiesState> emit,
  ) async {
    final current = state;
    if (current is! OrganizationOpportunitiesLoaded) return;
    if (current.isLoadingMore || current.hasReachedEnd) return;
    if (_isFetching) return;

    _isFetching = true;
    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final response = await organizationService.getOpportunitiesByOrganizationId(
        organizationId: organizationId,
        page: nextPage,
        size: current.pageSize,
        filter: _currentFilter,
      );

      final merged = <OpportunityResponse>[
        ...current.opportunities,
        ...response.content,
      ];
      final uniqueById = <int, OpportunityResponse>{};
      for (final opportunity in merged) {
        uniqueById[opportunity.id] = opportunity;
      }

      emit(
        current.copyWith(
          opportunities: uniqueById.values.toList(),
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: nextPage,
          isLoadingMore: false,
          filter: _currentFilter,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onApplyFilter(
    ApplyOrganizationOpportunitiesFilter event,
    Emitter<OrganizationOpportunitiesState> emit,
  ) async {
    _currentFilter = event.filter;
    await _onLoad(const LoadOrganizationOpportunities(), emit);
  }
}
