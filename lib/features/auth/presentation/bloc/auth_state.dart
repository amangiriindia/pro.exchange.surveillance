import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isProcessing;
  final bool isProfileLoading;
  final String? errorMessage;
  final String? profileErrorMessage;
  final ProfileDetails? profile;
  const AuthAuthenticated({
    required this.user,
    this.isProcessing = false,
    this.isProfileLoading = false,
    this.errorMessage,
    this.profileErrorMessage,
    this.profile,
  });

  AuthAuthenticated copyWith({
    User? user,
    bool? isProcessing,
    bool? isProfileLoading,
    String? errorMessage,
    String? profileErrorMessage,
    ProfileDetails? profile,
    bool clearErrorMessage = false,
    bool clearProfileErrorMessage = false,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      isProcessing: isProcessing ?? this.isProcessing,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      profileErrorMessage: clearProfileErrorMessage
          ? null
          : (profileErrorMessage ?? this.profileErrorMessage),
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isProcessing,
    isProfileLoading,
    errorMessage,
    profileErrorMessage,
    profile,
  ];
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}
