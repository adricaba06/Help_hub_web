part of 'application_bloc.dart';

@immutable
sealed class ApplicationsState {}

final class ApplicationsInitial extends ApplicationsState {}

final class ApplicationsLoading extends ApplicationsState {
  final String? selectedStatus;

  ApplicationsLoading({this.selectedStatus});
}

final class ApplicationsLoaded extends ApplicationsState {
  final List<ApplicationResponse> applications;
  final String? selectedStatus;
  final int totalElements;
  final int totalPages;
  final bool isLastPage;

  ApplicationsLoaded({
    required this.applications,
    required this.selectedStatus,
    required this.totalElements,
    required this.totalPages,
    required this.isLastPage,
  });
}

final class ApplicationsError extends ApplicationsState {
  final String message;
  final String? selectedStatus;

  ApplicationsError({
    required this.message,
    this.selectedStatus,
  });
}
