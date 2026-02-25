part of 'application_bloc.dart';

@immutable
sealed class ApplicationsEvent {}

final class ApplicationsRequested extends ApplicationsEvent {
  final int userId;
  final String? status;
  final int page;
  final int size;

  ApplicationsRequested({
    required this.userId,
    this.status,
    this.page = 0,
    this.size = 8,
  });
}
