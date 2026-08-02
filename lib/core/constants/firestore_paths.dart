/// Single source of truth for Firestore collection/document paths.
/// If a collection name ever changes, it changes here only.
abstract class FirestorePaths {
  static const String users = 'users';
  static const String chats = 'chats';
  static const String messages = 'messages';

  /// 'chats/{chatId}/messages'
  static String chatMessages(String chatId) => '$chats/$chatId/$messages';

  // Document fields (used in queries and updates)
  static const String fieldParticipants = 'participants';
  static const String fieldLastMessage = 'lastMessage';
  static const String fieldLastMessageTime = 'lastMessageTime';
  static const String fieldLastMessageSenderId = 'lastMessageSenderId';
  static const String fieldUnreadCount = 'unreadCount';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldSenderId = 'senderId';
  static const String fieldRead = 'read';
}
