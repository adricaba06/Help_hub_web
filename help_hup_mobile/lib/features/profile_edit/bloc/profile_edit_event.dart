part of 'profile_edit_bloc.dart';

@immutable
sealed class ProfileEditEvent {}

class ProfileEditSubmitted extends ProfileEditEvent {
  final String newName;

  ProfileEditSubmitted({required this.newName});
}
