import 'package:authentication_app/models/message_model.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';

class senderBubble extends StatelessWidget {
  const senderBubble({super.key, required this.message});
  final MessageModel message;
  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      clipper: ChatBubbleClipper9(type: BubbleType.sendBubble),
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(top: 20),
      backGroundColor: Color.fromARGB(255, 243, 178, 255),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          children: [
            Text(
              message.text,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(179, 5, 3, 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class receiverBubble extends StatelessWidget {
  const receiverBubble({super.key, required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      clipper: ChatBubbleClipper9(type: BubbleType.receiverBubble),
      backGroundColor: Colors.white,
      margin: EdgeInsets.only(top: 20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          children: [
            Text(
              message.text,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(179, 5, 3, 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime? time) {
  if (time == null) return '--:--';
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
