import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/failure.dart';
import 'message_datasource.dart';
import 'message_model.dart';

/// Message business logic — converts Firebase errors into [Failure]s.
class MessageRepo {
  MessageRepo(this._dataSource);

  final MessageDataSource _dataSource;

  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _dataSource.watchMessages(chatId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    String type = 'text',
  }) async {
    try {
      await _dataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        type: type,
      );
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }

  /// Best-effort: read receipts must never break the chat UI.
  Future<void> markAllAsRead({
    required String chatId,
    required String currentUid,
  }) async {
    try {
      await _dataSource.markAllAsRead(chatId: chatId, currentUid: currentUid);
    } catch (e) {
      // Never break the UI, but keep the failure visible in debug
      // (missing composite index / rules issues show up here).
      debugPrint('MessageRepo.markAllAsRead failed: $e');
    }
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _dataSource.deleteMessage(chatId: chatId, messageId: messageId);
    } on FirebaseException catch (e) {
      throw FirestoreFailure.fromException(e);
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }
}
