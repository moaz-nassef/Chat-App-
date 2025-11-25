class Message {
  final String text;
  // final bool isSentByMe;

  final String email;
  final DateTime time;

  Message({
    required this.text,
    required this.time,
    required this.email,
    // required this.isSentByMe,
  }); //  });

  factory Message.fromJson(Map jsonData) {
    return Message(
      text: jsonData['messages']?.toString() ?? '',
      email: jsonData['email']?.toString() ?? '',
      time: (jsonData['time']).toDate(),
      // isSentByMe: jsonData['isSentByMe'] ?? false,
    );
  }
}
