import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../auth/data/user_model.dart';

/// Reads from the Firestore `users` collection.
class UsersDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// All users (real-time). Filtering is done client-side.
  Stream<List<UserModel>> watchUsers() {
    return _firestore
        .collection(FirestorePaths.users)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  /// Single user (real-time) — used for the chat app-bar online status.
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
