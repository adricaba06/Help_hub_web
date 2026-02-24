import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/user_response.dart';
import '../../../core/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;

  ProfileBloc(this.profileService) : super(ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final user = await profileService.getMyProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
<<<<<<< HEAD
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ProfileError(message: message));
=======
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(ProfileError(message: errorMessage));
>>>>>>> 30cb3fff35d7203e6d288c0b04b7957cf05672b8
    }
  }
}
