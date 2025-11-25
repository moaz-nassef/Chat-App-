import 'package:authentication_app/pages/Message%20Model%20.dart';
import 'package:flutter/material.dart';
// ✅ Chat Bubble Widget
// class ChatBubble extends StatelessWidget {
//   final Message message;

//   const ChatBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Row(
//         mainAxisAlignment:
//             message.isSentByMe
//                 ? MainAxisAlignment.end
//                 : MainAxisAlignment.start,
//         children: [
//           // ✅ Avatar للطرف الآخر
//           if (!message.isSentByMe)
//             Padding(
//               padding: EdgeInsets.only(right: 8),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xFF9C27B0),
//                 radius: 16,
//                 child: Icon(Icons.person, color: Colors.white, size: 18),
//               ),
//             ),

//           // ✅ Message bubble
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.7,
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color:
//                     message.isSentByMe
//                         ? Color.fromARGB(255, 158, 94, 170)
//                         : const Color.fromARGB(255, 237, 209, 209),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                   bottomLeft:
//                       message.isSentByMe
//                           ? Radius.circular(20)
//                           : Radius.circular(4),
//                   bottomRight:
//                       message.isSentByMe
//                           ? Radius.circular(4)
//                           : Radius.circular(20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message.text,
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: message.isSentByMe ? Colors.white : Colors.black87,
//                       height: 1.4,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _formatTime(message.time),
//                     style: TextStyle(
//                       fontSize: 11,
//                       color:
//                           message.isSentByMe
//                               ? Colors.white70
//                               : Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ✅ Avatar ليك
//           if (message.isSentByMe)
//             Padding(
//               padding: EdgeInsets.only(left: 8),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xFFE1BEE7),
//                 radius: 16,
//                 child: Icon(Icons.person, color: Color(0xFF9C27B0), size: 18),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ✅ Format time
//   String _formatTime(DateTime time) {
//     final hour = time.hour.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
// }

class sendtmoazChatBubble extends StatelessWidget {
  sendtmoazChatBubble({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: 2, bottom: 5, left: 12, right: 12),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 235, 190, 244),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(20),
            // bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
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
      ),
    );
  }
}

class restmoazChatBubble extends StatelessWidget {
  restmoazChatBubble({super.key, required this.message});
  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.only(top: 2, bottom: 5, left: 12, right: 12),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 147, 206, 216),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            // bottomRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
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
      ),
    );
  }
}
