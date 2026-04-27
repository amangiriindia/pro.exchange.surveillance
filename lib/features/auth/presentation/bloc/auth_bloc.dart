import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final ChangePassword changePassword;
  final GetProfile getProfile;
  final LogoutUser logoutUser;
  AuthBloc({
    required this.loginUser,
    required this.changePassword,
    required this.getProfile,
    required this.logoutUser,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<ChangePasswordEvent>(_onChangePassword);
    on<FetchProfileEvent>(_onFetchProfile);
    on<RestoreSessionEvent>(_onRestoreSession);
    on<LogoutEvent>(_onLogout);

    add(const RestoreSessionEvent());
  }

  Future<void> _onRestoreSession(
    RestoreSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    final savedUser = await AuthLocalDataSource.instance.getUserSession();
    if (savedUser != null && savedUser.jwtToken.isNotEmpty) {
      emit(AuthAuthenticated(user: savedUser));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUser(
      LoginParams(username: event.username, password: event.password),
    );

    await result.fold<Future<void>>(
      (failure) async => emit(
        AuthError(message: failure.message.replaceFirst('Exception: ', '')),
      ),
      (user) async {
        await AuthLocalDataSource.instance.saveUserSession(user);
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    if (currentState.isProfileLoading) return;

    emit(
      currentState.copyWith(
        isProfileLoading: true,
        clearProfileErrorMessage: true,
      ),
    );

    final result = await getProfile(
      GetProfileParams(token: currentState.user.jwtToken),
    );

    result.fold(
      (failure) => emit(
        currentState.copyWith(
          isProfileLoading: false,
          profileErrorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        currentState.copyWith(
          isProfileLoading: false,
          profile: profile,
          clearProfileErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(const AuthUnauthenticated(message: 'Please login again'));
      return;
    }

    emit(currentState.copyWith(isProcessing: true, clearErrorMessage: true));

    final result = await changePassword(
      ChangePasswordParams(
        token: currentState.user.jwtToken,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    await result.fold<Future<void>>(
      (failure) async => emit(
        currentState.copyWith(
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (message) async {
        await AuthLocalDataSource.instance.clearUserSession();
        emit(AuthUnauthenticated(message: message));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      await AuthLocalDataSource.instance.clearUserSession();
      emit(const AuthUnauthenticated(message: 'Logout successful'));
      return;
    }

    emit(currentState.copyWith(isProcessing: true, clearErrorMessage: true));

    final result = await logoutUser(
      LogoutParams(token: currentState.user.jwtToken),
    );

    await AuthLocalDataSource.instance.clearUserSession();

    result.fold(
      (_) => emit(const AuthUnauthenticated(message: 'Logout successful')),
      (message) => emit(AuthUnauthenticated(message: message)),
    );
  }
}
