import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/profile_service.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ProfileService profileService;

  ChangePasswordBloc(this.profileService) : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());

    try {
      await profileService.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );
      emit(ChangePasswordSuccess());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(ChangePasswordFailure(message: message));
    }
  }
}
