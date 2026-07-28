import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authentication_app/models/message_model.dart';

class FirestoreMessageDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final batch = _firestore.batch();

    // Ensure chat document exists before writing messages.
    batch.set(chatRef, {
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': '',
    }, SetOptions(merge: true));

    // Add message to messages subcollection.
    final msgRef = chatRef.collection('messages').doc();
    batch.set(msgRef, {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'read': false,
    });

    // Update last message in chat.
    batch.set(chatRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
    }, SetOptions(merge: true));

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        code: e.code,
        message: 'Failed to send message: ${e.message}',
      );
    }
  }

  // Get messages for a chat (real-time)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get messages for a chat (one-time fetch)
  Future<List<MessageModel>> getMessagesOnce(String chatId) async {
    final snapshot =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
  }

  // Mark message as read
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  // Mark all messages as read for a user
  Future<void> markAllMessagesAsRead({
    required String chatId,
    required String currentUid,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUid)
              .where('read', isEqualTo: false)
              .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't rethrow - just log the error
    }
  }

  // Delete a message
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Get unread messages count for a user in a chat
  Future<int> getUnreadMessagesCount({
    required String chatId,
    required String currentUid,
  }) async {
    final snapshot =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: currentUid)
            .where('read', isEqualTo: false)
            .get();

    return snapshot.docs.length;
  }
}
