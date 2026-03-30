class Message {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime? time;
  final String status;

  Message({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.time,
    this.status = 'sent',
  });

  factory Message.fromJson(Map jsonData) {
    return Message(
      text:
          jsonData['text']?.toString() ??
          jsonData['messages']?.toString() ??
          '',
      senderId:
          jsonData['senderId']?.toString() ??
          jsonData['email']?.toString() ??
          '',
      receiverId: jsonData['receiverId']?.toString() ?? '',
      time: jsonData['createdAt']?.toDate() ?? jsonData['time']?.toDate(),
      status: jsonData['status']?.toString() ?? 'sent',
    );
  }
}
