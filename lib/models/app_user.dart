class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? lastSeen;
  final bool isOnline;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.lastSeen,
    this.isOnline = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email']?.toString() ?? '',
      displayName: data['displayName']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString(),
      lastSeen: data['lastSeen']?.toDate(),
      isOnline: data['isOnline'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
    };
  }
}
