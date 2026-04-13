import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  const LoginEvent({required this.username, required this.password});
  @override
  List<Object?> get props => [username, password];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class FetchProfileEvent extends AuthEvent {
  const FetchProfileEvent();
}

class RestoreSessionEvent extends AuthEvent {
  const RestoreSessionEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
