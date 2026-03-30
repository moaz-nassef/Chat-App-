import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authentication_app/models/chat_model.dart';

class FirestoreChatDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique chat ID from two user IDs
  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Create or get existing chat
  Future<String> createOrGetChat({
    required String currentUid,
    required String otherUid,
    required String currentEmail,
    required String otherEmail,
  }) async {
    final chatId = getChatId(currentUid, otherUid);
    final chatRef = _firestore.collection('chats').doc(chatId);

    final doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        'participants': [currentUid, otherUid],
        'participantsEmails': [currentEmail, otherEmail],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'unreadCount': {currentUid: 0, otherUid: 0},
      });
    }

    return chatId;
  }

  // Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) return null;
    return ChatModel.fromFirestore(doc);
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getMyChats(String myUid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList(),
        );
  }

  // Update last message in chat
  Future<void> updateLastMessage({
    required String chatId,
    required String message,
    required String senderId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    });
  }

  // Update unread count for a user
  Future<void> updateUnreadCount({
    required String chatId,
    required String uid,
    required int count,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$uid': count,
    });
  }

  // Reset unread count for a user
  Future<void> resetUnreadCount({
    required String chatId,
    required String uid,
  }) async {
    await updateUnreadCount(chatId: chatId, uid: uid, count: 0);
  }

  // Increment unread count for a user
  Future<void> incrementUnreadCount({
    required String chatId,
    required String uid,
  }) async {
    final chat = await getChatById(chatId);
    if (chat != null) {
      final currentCount = chat.getUnreadCountForUser(uid);
      await updateUnreadCount(
        chatId: chatId,
        uid: uid,
        count: currentCount + 1,
      );
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    // Delete all messages in the chat
    final messagesSnapshot =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .get();

    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the chat document
    batch.delete(_firestore.collection('chats').doc(chatId));

    await batch.commit();
  }
}
