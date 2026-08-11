import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CallStatus { creating, ringing, incoming, connecting, connected, ended }

/// Immutable representation of a 1:1 audio-call signalling document.
class CallModel extends Equatable {
  const CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerPhotoUrl,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String callerId;
  final String callerName;
  final String? callerPhotoUrl;
  final String receiverId;
  final CallStatus status;
  final DateTime createdAt;

  factory CallModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawStatus = data['status'] as String?;
    return CallModel(
      id: doc.id,
      callerId: data['callerId'] as String? ?? '',
      callerName: data['callerName'] as String? ?? 'مستخدم',
      callerPhotoUrl: data['callerPhotoUrl'] as String?,
      receiverId: data['receiverId'] as String? ?? '',
      status: CallStatus.values.firstWhere(
        (status) => status.name == rawStatus,
        orElse: () => CallStatus.ended,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    callerId,
    callerName,
    callerPhotoUrl,
    receiverId,
    status,
    createdAt,
  ];
}
