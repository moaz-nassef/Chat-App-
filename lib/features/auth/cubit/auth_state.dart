import 'package:equatable/equatable.dart';

import '../data/user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App just started, auth status not known yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A blocking auth action is running (login / signup / reset password).
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Signed in — carries the full user profile.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

/// Signed out.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Action failed — shown as a SnackBar via BlocListener.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Password-reset email sent successfully.
final class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
