import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// App user profile (Firestore `users` collection).
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.online = false,
    this.lastSeen,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool online;
  final DateTime? lastSeen;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      online: data['online'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  /// Fallback built from the FirebaseAuth user (when no Firestore doc exists).
  factory UserModel.fromFirebaseUser(String uid, String? email, String? name) {
    return UserModel(
      uid: uid,
      email: email ?? '',
      displayName: name ?? email?.split('@').first ?? 'User',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'online': online,
      'lastSeen':
          lastSeen != null
              ? Timestamp.fromDate(lastSeen!)
              : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? online,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// First letter used in avatars.
  String get initial =>
      displayName.isNotEmpty
          ? displayName[0].toUpperCase()
          : (email.isNotEmpty ? email[0].toUpperCase() : '?');

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    online,
    lastSeen,
  ];
}
