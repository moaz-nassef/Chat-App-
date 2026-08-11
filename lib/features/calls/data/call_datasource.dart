import 'package:cloud_firestore/cloud_firestore.dart';

import 'call_model.dart';

/// Raw Cloud Firestore access for WebRTC signalling documents.
class CallDataSource {
  CallDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _calls =>
      _firestore.collection('calls');

  Future<String> createCall({
    required String callerId,
    required String callerName,
    required String? callerPhotoUrl,
    required String receiverId,
  }) async {
    final doc = _calls.doc();
    await doc.set({
      'callerId': callerId,
      'callerName': callerName,
      'callerPhotoUrl': callerPhotoUrl,
      'receiverId': receiverId,
      'status': CallStatus.creating.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> publishOffer({
    required String callId,
    required String type,
    required String sdp,
  }) => _calls.doc(callId).update({
    'offer': {'type': type, 'sdp': sdp},
    'status': CallStatus.ringing.name,
  });

  Future<Map<String, String>> getOffer(String callId) async {
    final data = (await _calls.doc(callId).get()).data();
    final offer = data?['offer'] as Map<String, dynamic>?;
    if (offer == null || offer['type'] is! String || offer['sdp'] is! String) {
      throw StateError('لم تعد المكالمة متاحة.');
    }
    return {'type': offer['type'] as String, 'sdp': offer['sdp'] as String};
  }

  Future<Map<String, String>> getAnswer(String callId) async {
    final data = (await _calls.doc(callId).get()).data();
    final answer = data?['answer'] as Map<String, dynamic>?;
    if (answer == null ||
        answer['type'] is! String ||
        answer['sdp'] is! String) {
      throw StateError('لم يصل رد المكالمة بعد.');
    }
    return {'type': answer['type'] as String, 'sdp': answer['sdp'] as String};
  }

  Future<void> publishAnswer({
    required String callId,
    required String type,
    required String sdp,
  }) => _calls.doc(callId).update({
    'answer': {'type': type, 'sdp': sdp},
    'status': CallStatus.connected.name,
  });

  Future<void> setStatus(String callId, CallStatus status) =>
      _calls.doc(callId).update({
        'status': status.name,
        'endedAt':
            status == CallStatus.ended ? FieldValue.serverTimestamp() : null,
      });

  /// Deletes the call document and its ICE candidates (cleanup).
  Future<void> deleteCall(String callId) async {
    final callRef = _calls.doc(callId);
    final batch = _firestore.batch();

    for (final collection in ['callerCandidates', 'calleeCandidates']) {
      final candidatesSnap = await callRef.collection(collection).get();
      for (final doc in candidatesSnap.docs) {
        batch.delete(doc.reference);
      }
    }

    batch.delete(callRef);
    await batch.commit();
  }

  Future<void> addCandidate({
    required String callId,
    required bool fromCaller,
    required String candidate,
    required String? sdpMid,
    required int? sdpMLineIndex,
  }) => _calls
      .doc(callId)
      .collection(fromCaller ? 'callerCandidates' : 'calleeCandidates')
      .add({
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      });

  Stream<CallModel?> watchCall(String callId) => _calls
      .doc(callId)
      .snapshots()
      .map(
        (document) =>
            document.exists ? CallModel.fromFirestore(document) : null,
      );

  Stream<List<CallModel>> watchIncomingCalls(String uid) => _calls
      .where('receiverId', isEqualTo: uid)
      .where('status', isEqualTo: CallStatus.ringing.name)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(CallModel.fromFirestore).toList());

  Stream<List<Map<String, Object?>>> watchRemoteCandidates({
    required String callId,
    required bool isCaller,
  }) => _calls
      .doc(callId)
      .collection(isCaller ? 'calleeCandidates' : 'callerCandidates')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docChanges
                .where((change) => change.type == DocumentChangeType.added)
                .map((change) {
                  final data = change.doc.data();
                  return Map<String, Object?>.from(data ?? const {});
                })
                .toList(),
      );
}
