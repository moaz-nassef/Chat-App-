import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/failure.dart';
import 'chat_datasource.dart';
import 'chat_model.dart';

/// Chat rooms business logic — converts Firebase errors into [Failure]s.
class ChatRepo {
  ChatRepo(this._dataSource);

  final ChatDataSource _dataSource;

  static String chatIdFor(String uid1, String uid2) =>
      ChatDataSource.chatIdFor(uid1, uid2);

  Stream<List<ChatModel>> watchMyChats(String myUid) {
    return _dataSource.watchMyChats(myUid);
  }

  Future<String> createOrGetChat({
    required String currentUid,
    required String otherUid,
    required String currentEmail,
    required String otherEmail,
  }) async {
    try {
      return await _dataSource.createOrGetChat(
        currentUid: currentUid,
        otherUid: otherUid,
        currentEmail: currentEmail,
        otherEmail: otherEmail,
      );
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _dataSource.deleteChat(chatId);
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }
}
