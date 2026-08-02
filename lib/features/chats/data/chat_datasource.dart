import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import 'chat_model.dart';

/// Raw Firestore access for the `chats` collection.
class ChatDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Deterministic 1:1 chat id: both users always compute the same id.
  static String chatIdFor(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Returns the chat id, creating the room on first contact.
  Future<String> createOrGetChat({
    required String currentUid,
    required String otherUid,
    required String currentEmail,
    required String otherEmail,
  }) async {
    final chatId = chatIdFor(currentUid, otherUid);
    final chatRef = _firestore.collection(FirestorePaths.chats).doc(chatId);

    final doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        FirestorePaths.fieldParticipants: [currentUid, otherUid],
        'participantsEmails': [currentEmail, otherEmail],
        FirestorePaths.fieldLastMessage: '',
        FirestorePaths.fieldLastMessageTime: FieldValue.serverTimestamp(),
        FirestorePaths.fieldLastMessageSenderId: '',
        FirestorePaths.fieldUnreadCount: {currentUid: 0, otherUid: 0},
      });
    }

    return chatId;
  }

  /// My chats, most recent first (real-time).
  Stream<List<ChatModel>> watchMyChats(String myUid) {
    return _firestore
        .collection(FirestorePaths.chats)
        .where(FirestorePaths.fieldParticipants, arrayContains: myUid)
        .orderBy(FirestorePaths.fieldLastMessageTime, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList(),
        );
  }

  /// Deletes the chat document + all its messages in one batch.
  Future<void> deleteChat(String chatId) async {
    final chatRef = _firestore.collection(FirestorePaths.chats).doc(chatId);
    final messagesSnapshot =
        await chatRef.collection(FirestorePaths.messages).get();

    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(chatRef);

    await batch.commit();
  }
}
