part of 'profile_edit_bloc.dart';

@immutable
sealed class ProfileEditState {}

final class ProfileEditInitial extends ProfileEditState {}

final class ProfileEditLoading extends ProfileEditState {}

final class ProfileEditSuccess extends ProfileEditState {
  final UserResponse user;
  
  ProfileEditSuccess({required this.user});
}

final class ProfileEditFailure extends ProfileEditState {
  final String message;

  ProfileEditFailure({required this.message});
}
