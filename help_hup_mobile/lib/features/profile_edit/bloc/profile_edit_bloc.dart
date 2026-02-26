import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/user_response.dart';
import '../../../core/services/profile_service.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final ProfileService profileService;

  ProfileEditBloc(this.profileService) : super(ProfileEditInitial()) {
    on<ProfileEditSubmitted>(_onProfileEditSubmitted);
    on<ProfilePictureUploadStarted>(_onProfilePictureUploadStarted);
    on<ProfileUserUpdated>(_onProfileUserUpdated);
  }

  Future<void> _onProfileEditSubmitted(
    ProfileEditSubmitted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(ProfileEditLoading());

    try {
      final user = await profileService.editProfile(newName: event.newName);
      emit(ProfileEditSuccess(user: user));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ProfileEditFailure(message: message));
    }
  }

  Future<void> _onProfilePictureUploadStarted(
    ProfilePictureUploadStarted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(ProfileEditLoading());

    try {
      final user = await profileService.uploadProfilePicture(imageFile: event.imageFile);
      emit(ProfileEditSuccess(
        user: user,
        imageUploaded: true,
      ));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ProfileEditFailure(message: message));
    }
  }

  Future<void> _onProfileUserUpdated(
    ProfileUserUpdated event,
    Emitter<ProfileEditState> emit,
  ) async {
    // Este evento puede usarse para sincronización futura si es necesario
  }
}
