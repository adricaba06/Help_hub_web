part of 'profile_edit_bloc.dart';

@immutable
sealed class ProfileEditState {}

final class ProfileEditInitial extends ProfileEditState {}

final class ProfileEditLoading extends ProfileEditState {}

final class ProfileEditSuccess extends ProfileEditState {
  final UserResponse user;
  final bool imageUploaded;

  ProfileEditSuccess({
    required this.user,
    this.imageUploaded = false,
  });
}

final class ProfileEditFailure extends ProfileEditState {
  final String message;

  ProfileEditFailure({required this.message});
}
