import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/failure.dart';
import 'call_datasource.dart';
import 'call_model.dart';

/// Maps Firestore failures and exposes call signalling operations to the Cubit.
class CallRepo {
  CallRepo(this._dataSource);

  final CallDataSource _dataSource;

  Future<String> createCall({
    required String callerId,
    required String callerName,
    required String? callerPhotoUrl,
    required String receiverId,
  }) => _guard(
    () => _dataSource.createCall(
      callerId: callerId,
      callerName: callerName,
      callerPhotoUrl: callerPhotoUrl,
      receiverId: receiverId,
    ),
  );

  Future<void> publishOffer({required String callId, required String type, required String sdp}) =>
      _guard(() => _dataSource.publishOffer(callId: callId, type: type, sdp: sdp));

  Future<Map<String, String>> getOffer(String callId) =>
      _guard(() => _dataSource.getOffer(callId));

  Future<Map<String, String>> getAnswer(String callId) =>
      _guard(() => _dataSource.getAnswer(callId));

  Future<void> publishAnswer({required String callId, required String type, required String sdp}) =>
      _guard(() => _dataSource.publishAnswer(callId: callId, type: type, sdp: sdp));

  Future<void> endCall(String callId) => _guard(
    () => _dataSource.setStatus(callId, CallStatus.ended),
  );

  /// Cleans up the call document and all ICE candidates after a call ends.
  Future<void> deleteCall(String callId) => _guard(
    () => _dataSource.deleteCall(callId),
  );

  Future<void> addCandidate({
    required String callId,
    required bool fromCaller,
    required String candidate,
    required String? sdpMid,
    required int? sdpMLineIndex,
  }) => _guard(
    () => _dataSource.addCandidate(
      callId: callId,
      fromCaller: fromCaller,
      candidate: candidate,
      sdpMid: sdpMid,
      sdpMLineIndex: sdpMLineIndex,
    ),
  );

  Stream<CallModel?> watchCall(String callId) => _dataSource.watchCall(callId);
  Stream<List<CallModel>> watchIncomingCalls(String uid) => _dataSource.watchIncomingCalls(uid);
  Stream<List<Map<String, Object?>>> watchRemoteCandidates({required String callId, required bool isCaller}) =>
      _dataSource.watchRemoteCandidates(callId: callId, isCaller: isCaller);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw FirestoreFailure.fromException(error);
    } catch (error) {
      throw UnknownFailure.fromException(error);
    }
  }
}
