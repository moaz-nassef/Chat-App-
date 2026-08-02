import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_paths.dart';

/// Raw FirebaseAuth + user-profile writes. No error mapping here —
/// repositories wrap these calls and throw [Failure]s.
class AuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Currently signed-in Firebase user (null when signed out).
  User? get currentUser => _auth.currentUser;

  /// Emits on every sign-in / sign-out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();

    await _createUserProfile(credential.user!);
    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await setOnlineStatus(credential.user!.uid, true);
    return credential;
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await setOnlineStatus(user.uid, false);
    }
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Public so PresenceService can toggle it with app lifecycle.
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).set({
      'online': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _createUserProfile(User user) async {
    await _firestore.collection(FirestorePaths.users).doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      'photoUrl': user.photoURL,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
