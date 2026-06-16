import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPasswordUpdateRequested>(_onPasswordUpdate);
    on<AuthProfileRefreshRequested>(_onProfileRefresh);
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCachedUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(event.email, event.password);
    result.fold(
      (error) => emit(AuthError(message: error)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onPasswordUpdate(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    final result = await _authRepository.resetPassword(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (error) {
        emit(AuthError(message: error));
        emit(currentState);
      },
      (_) async {
        // Refresh profile after password update
        add(const AuthProfileRefreshRequested());
      },
    );
  }

  Future<void> _onProfileRefresh(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    final result = await _authRepository.getProfile(currentState.user.id);
    result.fold(
      (error) {
        // Just keep the current state if refresh fails
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
