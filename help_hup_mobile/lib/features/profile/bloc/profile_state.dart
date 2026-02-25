part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserResponse user;

  ProfileLoaded({required this.user});
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
