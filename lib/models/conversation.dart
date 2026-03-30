class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> data) {
    return Conversation(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage']?.toString() ?? '',
      lastMessageAt: data['lastMessageAt']?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId']?.toString(),
    );
  }
}
