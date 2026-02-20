import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/opportunity_response.dart';
import '../../../core/services/opportunity_service.dart';

part 'opportunity_event.dart';
part 'opportunity_state.dart';

class OpportunityBloc extends Bloc<OpportunityEvent, OpportunityState> {
  final OpportunityService opportunityService;

  OpportunityBloc(this.opportunityService) : super(OpportunityInitial()) {
    on<OpportunitySearchRequested>(_onSearchRequested);
    on<OpportunityCityFilterChanged>(_onCityFilterChanged);
    on<OpportunityDateRangeChanged>(_onDateRangeChanged);
    on<OpportunityFiltersCleared>(_onFiltersCleared);
  }

  String? _currentCity;
  DateTime? _currentDateFrom;
  DateTime? _currentDateTo;
  String _currentSearchQuery = '';

  Future<void> _onSearchRequested(
    OpportunitySearchRequested event,
    Emitter<OpportunityState> emit,
  ) async {
    _currentSearchQuery = event.query;
    emit(OpportunityLoading());

    try {
      final opportunities = await opportunityService.searchOpportunities(
        query: event.query.isEmpty ? null : event.query,
        city: _currentCity,
        dateFrom: _currentDateFrom,
        dateTo: _currentDateTo,
      );

      emit(OpportunityLoaded(
        opportunities: opportunities,
        selectedCity: _currentCity,
        filterDateFrom: _currentDateFrom,
        filterDateTo: _currentDateTo,
        searchQuery: event.query,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(OpportunityError(
        message: errorMessage,
        selectedCity: _currentCity,
        filterDateFrom: _currentDateFrom,
        filterDateTo: _currentDateTo,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onCityFilterChanged(
    OpportunityCityFilterChanged event,
    Emitter<OpportunityState> emit,
  ) async {
    _currentCity = event.city;
    emit(OpportunityLoading());

    try {
      final opportunities = await opportunityService.searchOpportunities(
        query: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
        city: event.city,
        dateFrom: _currentDateFrom,
        dateTo: _currentDateTo,
      );

      emit(OpportunityLoaded(
        opportunities: opportunities,
        selectedCity: event.city,
        filterDateFrom: _currentDateFrom,
        filterDateTo: _currentDateTo,
        searchQuery: _currentSearchQuery,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(OpportunityError(
        message: errorMessage,
        selectedCity: event.city,
        filterDateFrom: _currentDateFrom,
        filterDateTo: _currentDateTo,
        searchQuery: _currentSearchQuery,
      ));
    }
  }

  Future<void> _onDateRangeChanged(
    OpportunityDateRangeChanged event,
    Emitter<OpportunityState> emit,
  ) async {
    _currentDateFrom = event.dateFrom;
    _currentDateTo = event.dateTo;
    emit(OpportunityLoading());

    try {
      final opportunities = await opportunityService.searchOpportunities(
        query: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
        city: _currentCity,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      emit(OpportunityLoaded(
        opportunities: opportunities,
        selectedCity: _currentCity,
        filterDateFrom: event.dateFrom,
        filterDateTo: event.dateTo,
        searchQuery: _currentSearchQuery,
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(OpportunityError(
        message: errorMessage,
        selectedCity: _currentCity,
        filterDateFrom: event.dateFrom,
        filterDateTo: event.dateTo,
        searchQuery: _currentSearchQuery,
      ));
    }
  }

  Future<void> _onFiltersCleared(
    OpportunityFiltersCleared event,
    Emitter<OpportunityState> emit,
  ) async {
    _currentCity = null;
    _currentDateFrom = null;
    _currentDateTo = null;
    _currentSearchQuery = '';
    emit(OpportunityLoading());

    try {
      final opportunities = await opportunityService.searchOpportunities(
        query: null,
        city: null,
        dateFrom: null,
        dateTo: null,
      );

      emit(OpportunityLoaded(
        opportunities: opportunities,
        selectedCity: null,
        filterDateFrom: null,
        filterDateTo: null,
        searchQuery: '',
      ));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(OpportunityError(
        message: errorMessage,
        selectedCity: null,
        filterDateFrom: null,
        filterDateTo: null,
        searchQuery: '',
      ));
    }
  }
}
