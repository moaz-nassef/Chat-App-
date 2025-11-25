import 'package:authentication_app/pages/Message%20Model%20.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_9.dart';
import 'package:flutter/material.dart';

class senderBubble extends StatelessWidget {
  const senderBubble({super.key, required this.message});
  final Message message;
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
              '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
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
  final Message message;

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
              '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
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
