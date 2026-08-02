import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A chat room (Firestore `chats` collection).
class ChatModel extends Equatable {
  const ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
  });

  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  /// The other participant's uid in a 1:1 chat ('' for malformed docs).
  String otherParticipantId(String currentUid) {
    return participants.firstWhere((id) => id != currentUid, orElse: () => '');
  }

  /// Unread badge count for [uid].
  int unreadFor(String uid) => unreadCount[uid] ?? 0;

  @override
  List<Object?> get props => [
    id,
    participants,
    lastMessage,
    lastMessageTime,
    lastMessageSenderId,
    unreadCount,
  ];
}
