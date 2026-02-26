part of 'change_password_bloc.dart';

@immutable
sealed class ChangePasswordEvent {}

final class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordSubmitted({
    required this.oldPassword,
    required this.newPassword,
  });
}
