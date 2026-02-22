part of 'register_page_bloc.dart';

@immutable
sealed class RegisterPageState {
  const RegisterPageState();
}

final class RegisterPageInitial extends RegisterPageState {
  const RegisterPageInitial();
}

final class RegisterPageLoading extends RegisterPageState {
  const RegisterPageLoading();
}

final class RegisterPageSuccess extends RegisterPageState {
  final String token;
  final Map<String, dynamic> user;

  const RegisterPageSuccess({
    required this.token,
    required this.user,
  });

}

final class RegisterPageError extends RegisterPageState {
  final String message;
  const RegisterPageError(this.message);
}
