part of 'opportunity_bloc.dart';

@immutable
sealed class OpportunityState {}

final class OpportunityInitial extends OpportunityState {}

final class OpportunityLoading extends OpportunityState {}

final class OpportunityLoaded extends OpportunityState {
  final List<OpportunityResponse> opportunities;
  final String? selectedCity;
  final DateTime? filterDateFrom;
  final DateTime? filterDateTo;
  final String searchQuery;

  OpportunityLoaded({
    required this.opportunities,
    this.selectedCity,
    this.filterDateFrom,
    this.filterDateTo,
    this.searchQuery = '',
  });
}

final class OpportunityError extends OpportunityState {
  final String message;
  final String? selectedCity;
  final DateTime? filterDateFrom;
  final DateTime? filterDateTo;
  final String searchQuery;

  OpportunityError({
    required this.message,
    this.selectedCity,
    this.filterDateFrom,
    this.filterDateTo,
    this.searchQuery = '',
  });
}
