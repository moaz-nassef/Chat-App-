import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../data/auth_repo.dart';
import 'auth_state.dart';

/// App-lifetime cubit: owns the auth session and listens to
/// Firebase auth changes. Registered as a singleton in the DI container.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(const AuthInitial()) {
    _authSub = _authRepo.watchAuthUser().listen((user) {
      // While a blocking action (login/signup/reset) runs, the action itself
      // emits the terminal state — authStateChanges() does NOT re-emit, so a
      // stream event swallowed here would leave the app stuck on AuthLoading.
      if (state is AuthLoading) return;
      emit(
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      );
    });
  }

  final AuthRepo _authRepo;
  late final StreamSubscription _authSub;

  String? get currentUid => _authRepo.currentUid;

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepo.signIn(email: email, password: password);
      // Emit explicitly — don't rely on the auth stream, whose event is
      // intentionally skipped above while this action is in progress.
      emit(AuthAuthenticated(user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthAuthenticated(user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(const AuthLoading());
    try {
      await _authRepo.sendPasswordResetEmail(email);
      emit(const AuthPasswordResetSent());
      emit(const AuthUnauthenticated());
    } on Failure catch (f) {
      emit(AuthError(f.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signOut() => _authRepo.signOut();

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
