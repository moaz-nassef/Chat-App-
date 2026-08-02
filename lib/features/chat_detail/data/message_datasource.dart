import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import 'message_model.dart';

/// Raw Firestore access for the `messages` subcollection.
class MessageDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _messagesRef(String chatId) => _firestore
      .collection(FirestorePaths.chats)
      .doc(chatId)
      .collection(FirestorePaths.messages);

  /// Sends a message atomically (one batch):
  /// 1. ensures the chat doc exists,
  /// 2. writes the message,
  /// 3. updates lastMessage on the chat,
  /// 4. increments the receiver's unread counter.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    String type = 'text',
  }) async {
    final chatRef = _firestore.collection(FirestorePaths.chats).doc(chatId);
    final batch = _firestore.batch();

    batch.set(chatRef, {
      FirestorePaths.fieldLastMessage: '',
      FirestorePaths.fieldLastMessageTime: FieldValue.serverTimestamp(),
      FirestorePaths.fieldLastMessageSenderId: '',
    }, SetOptions(merge: true));

    final msgRef = _messagesRef(chatId).doc();
    batch.set(msgRef, {
      FirestorePaths.fieldSenderId: senderId,
      'text': text,
      FirestorePaths.fieldTimestamp: FieldValue.serverTimestamp(),
      'type': type,
      FirestorePaths.fieldRead: false,
    });

    batch.set(chatRef, {
      FirestorePaths.fieldLastMessage: text,
      FirestorePaths.fieldLastMessageTime: FieldValue.serverTimestamp(),
      FirestorePaths.fieldLastMessageSenderId: senderId,
      '${FirestorePaths.fieldUnreadCount}.$receiverId': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Real-time stream, newest first.
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _messagesRef(chatId)
        .orderBy(FirestorePaths.fieldTimestamp, descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Marks every incoming message as read AND resets my unread counter
  /// in a single batch — keeps the chats-list badge in sync.
  Future<void> markAllAsRead({
    required String chatId,
    required String currentUid,
  }) async {
    final snapshot =
        await _messagesRef(chatId)
            .where(FirestorePaths.fieldSenderId, isNotEqualTo: currentUid)
            .where(FirestorePaths.fieldRead, isEqualTo: false)
            .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {FirestorePaths.fieldRead: true});
    }

    batch.set(
      _firestore.collection(FirestorePaths.chats).doc(chatId),
      {'${FirestorePaths.fieldUnreadCount}.$currentUid': 0},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _messagesRef(chatId).doc(messageId).delete();
  }
}
