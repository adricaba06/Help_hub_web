part of 'organization_list_page_bloc.dart';

@immutable
sealed class OrganizationListPageState {}

final class OrganizationListPageInitial extends OrganizationListPageState {}

final class OrganizationListPageLoading extends OrganizationListPageState {}

final class OrganizationListPageLoaded extends OrganizationListPageState {
  final List<Organization> organizations;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool isLoadingMore;
  final int pageSize;

  bool get hasReachedEnd =>
      organizations.length >= totalElements || currentPage + 1 >= totalPages;

  OrganizationListPageLoaded({
    required this.organizations,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    this.isLoadingMore = false,
  });

  OrganizationListPageLoaded copyWith({
    List<Organization>? organizations,
    int? totalElements,
    int? totalPages,
    int? currentPage,
    bool? isLoadingMore,
    int? pageSize,
  }) {
    return OrganizationListPageLoaded(
      organizations: organizations ?? this.organizations,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

final class OrganizationListPageError extends OrganizationListPageState {
  final String error;

  OrganizationListPageError({required this.error});
}
