import 'package:authentication_app/models/user_model.dart';
import 'package:authentication_app/models/chat_model.dart';
import 'package:authentication_app/models/message_model.dart';
import 'package:authentication_app/data/datasources/firebase_auth_datasource.dart';
import 'package:authentication_app/data/datasources/firestore_chat_datasource.dart';
import 'package:authentication_app/data/datasources/firestore_message_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseAuthDataSource _authDataSource = FirebaseAuthDataSource();
  final FirestoreChatDataSource _chatDataSource = FirestoreChatDataSource();
  final FirestoreMessageDataSource _messageDataSource =
      FirestoreMessageDataSource();

  // Get current user
  User? get currentUser => _authDataSource.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _authDataSource.authStateChanges;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _authDataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _authDataSource.signIn(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    return await _authDataSource.getUserById(uid);
  }

  // Search user by email
  Future<UserModel?> searchUserByEmail(String email) async {
    return await _authDataSource.searchUserByEmail(email);
  }

  // Get all users except current user
  Stream<List<UserModel>> getAllUsersExcept(String currentUid) {
    return _authDataSource.getAllUsersExcept(currentUid);
  }

  // Create or get existing chat
  Future<String> createOrGetChat({
    required String currentUid,
    required String otherUid,
    required String currentEmail,
    required String otherEmail,
  }) async {
    return await _chatDataSource.createOrGetChat(
      currentUid: currentUid,
      otherUid: otherUid,
      currentEmail: currentEmail,
      otherEmail: otherEmail,
    );
  }

  // Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    return await _chatDataSource.getChatById(chatId);
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getMyChats(String myUid) {
    return _chatDataSource.getMyChats(myUid);
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
  }) async {
    await _messageDataSource.sendMessage(
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: type,
    );
  }

  // Get messages for a chat (real-time)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _messageDataSource.getMessages(chatId);
  }

  // Get messages for a chat (one-time fetch)
  Future<List<MessageModel>> getMessagesOnce(String chatId) async {
    return await _messageDataSource.getMessagesOnce(chatId);
  }

  // Mark message as read
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    await _messageDataSource.markMessageAsRead(
      chatId: chatId,
      messageId: messageId,
    );
  }

  // Mark all messages as read for a user
  Future<void> markAllMessagesAsRead({
    required String chatId,
    required String currentUid,
  }) async {
    await _messageDataSource.markAllMessagesAsRead(
      chatId: chatId,
      currentUid: currentUid,
    );
  }

  // Delete a message
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await _messageDataSource.deleteMessage(
      chatId: chatId,
      messageId: messageId,
    );
  }

  // Get unread messages count for a user in a chat
  Future<int> getUnreadMessagesCount({
    required String chatId,
    required String currentUid,
  }) async {
    return await _messageDataSource.getUnreadMessagesCount(
      chatId: chatId,
      currentUid: currentUid,
    );
  }

  // Reset unread count for a user
  Future<void> resetUnreadCount({
    required String chatId,
    required String uid,
  }) async {
    await _chatDataSource.resetUnreadCount(chatId: chatId, uid: uid);
  }

  // Increment unread count for a user
  Future<void> incrementUnreadCount({
    required String chatId,
    required String uid,
  }) async {
    await _chatDataSource.incrementUnreadCount(chatId: chatId, uid: uid);
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    await _chatDataSource.deleteChat(chatId);
  }
}
