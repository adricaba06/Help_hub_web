part of 'opportunity_bloc.dart';

@immutable
sealed class OpportunityEvent {}

class OpportunitySearchRequested extends OpportunityEvent {
  final String query;

  OpportunitySearchRequested(this.query);
}

class OpportunityCityFilterChanged extends OpportunityEvent {
  final String? city;

  OpportunityCityFilterChanged(this.city);
}

class OpportunityDateRangeChanged extends OpportunityEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  OpportunityDateRangeChanged(this.dateFrom, this.dateTo);
}

class OpportunityFiltersCleared extends OpportunityEvent {}
