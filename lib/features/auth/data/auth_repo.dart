import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/failure.dart';
import '../../users/data/users_datasource.dart';
import 'auth_datasource.dart';
import 'user_model.dart';

/// Auth business logic. Wraps [AuthDataSource]/[UsersDataSource]
/// and converts Firebase exceptions into [Failure]s.
class AuthRepo {
  AuthRepo(this._authDataSource, this._usersDataSource);

  final AuthDataSource _authDataSource;
  final UsersDataSource _usersDataSource;

  String? get currentUid => _authDataSource.currentUser?.uid;
  String? get currentEmail => _authDataSource.currentUser?.email;

  /// Emits whenever the signed-in state flips (true = signed in).
  /// Lightweight (no profile fetch) — used by PresenceService so a
  /// failing profile read can never kill presence tracking.
  Stream<bool> get signedInChanges =>
      _authDataSource.authStateChanges.map((user) => user != null);

  /// Emits the full [UserModel] profile on every auth change
  /// (null when signed out).
  Stream<UserModel?> watchAuthUser() {
    return _authDataSource.authStateChanges.asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return _profileFor(fbUser);
    });
  }

  /// Firestore profile for [user], falling back to the FirebaseAuth
  /// fields when the document doesn't exist yet.
  Future<UserModel> _profileFor(User user) async {
    final profile = await _usersDataSource.getUserById(user.uid);
    return profile ??
        UserModel.fromFirebaseUser(user.uid, user.email, user.displayName);
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authDataSource.signIn(
        email: email,
        password: password,
      );
      return await _profileFor(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromException(e);
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _authDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return await _profileFor(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromException(e);
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _authDataSource.setOnlineStatus(uid, isOnline);
    } catch (e) {
      // Presence is best-effort — never crash the app for it,
      // but log so permission/rules issues are visible in debug.
      debugPrint('AuthRepo.setOnlineStatus($isOnline) failed: $e');
    }
  }
}
