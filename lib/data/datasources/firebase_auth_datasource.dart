import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authentication_app/models/user_model.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();

    // Create user profile in Firestore
    await _createUserProfile(credential.user!);

    return credential;
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update online status
    await _updateUserOnlineStatus(credential.user!.uid, true);

    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _updateUserOnlineStatus(user.uid, false);
    }
    await _auth.signOut();
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      'photoUrl': user.photoURL,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Update user online status
  Future<void> _updateUserOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('users').doc(uid).update({
      'online': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Search user by email
  Future<UserModel?> searchUserByEmail(String email) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }

  // Get all users except current user
  Stream<List<UserModel>> getAllUsersExcept(String currentUid) {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .where((doc) => doc.id != currentUid)
                  .map((doc) => UserModel.fromFirestore(doc))
                  .toList(),
        );
  }
}
