part of 'register_page_bloc.dart';

@immutable
sealed class RegisterPageEvent {
  const RegisterPageEvent();
}

final class RegisterSubmitted extends RegisterPageEvent {
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });

  final String email;
  final String password;
  final String displayName;
  final String role;
}
