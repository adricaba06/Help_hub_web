import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/services/UserService.dart';

part 'register_page_event.dart';
part 'register_page_state.dart';

class RegisterPageBloc extends Bloc<RegisterPageEvent, RegisterPageState> {
  RegisterPageBloc({required Userservice userService})
      : _userService = userService,
        super(const RegisterPageInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final Userservice _userService;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterPageState> emit,
  ) async {
    emit(const RegisterPageLoading());

    try {
      final response = await _userService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      );

      final token = response['token']?.toString() ?? '';
      final userDynamic = response['user'];
      final user = userDynamic is Map<String, dynamic>
          ? userDynamic
          : <String, dynamic>{};

      emit(RegisterPageSuccess(token: token, user: user));
    } catch (e) {
      emit(RegisterPageError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
