part of 'organization_opportunities_bloc.dart';

@immutable
sealed class OrganizationOpportunitiesState {}

final class OrganizationOpportunitiesInitial
    extends OrganizationOpportunitiesState {}

final class OrganizationOpportunitiesLoading
    extends OrganizationOpportunitiesState {}

final class OrganizationOpportunitiesLoaded
    extends OrganizationOpportunitiesState {
  final List<OpportunityResponse> opportunities;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isLoadingMore;

  bool get hasReachedEnd =>
      opportunities.length >= totalElements || currentPage + 1 >= totalPages;

  OrganizationOpportunitiesLoaded({
    required this.opportunities,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    this.isLoadingMore = false,
  });

  OrganizationOpportunitiesLoaded copyWith({
    List<OpportunityResponse>? opportunities,
    int? totalElements,
    int? totalPages,
    int? currentPage,
    int? pageSize,
    bool? isLoadingMore,
  }) {
    return OrganizationOpportunitiesLoaded(
      opportunities: opportunities ?? this.opportunities,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class OrganizationOpportunitiesError extends OrganizationOpportunitiesState {
  final String error;

  OrganizationOpportunitiesError({required this.error});
}
