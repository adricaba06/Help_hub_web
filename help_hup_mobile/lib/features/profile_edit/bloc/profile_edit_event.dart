part of 'profile_edit_bloc.dart';

@immutable
sealed class ProfileEditEvent {}

class ProfileEditSubmitted extends ProfileEditEvent {
  final String newName;

  ProfileEditSubmitted({required this.newName});
}

class ProfilePictureUploadStarted extends ProfileEditEvent {
  final File imageFile;

  ProfilePictureUploadStarted({required this.imageFile});
}

class ProfileUserUpdated extends ProfileEditEvent {
  final UserResponse user;

  ProfileUserUpdated({required this.user});
}
