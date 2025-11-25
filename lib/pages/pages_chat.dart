import 'package:authentication_app/pages/ChatBubble_Widget.dart';
import 'package:authentication_app/pages/Message%20Model%20.dart';
import 'package:authentication_app/pages/Widget__chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  CollectionReference massages = FirebaseFirestore.instance.collection(
    'messages',
  );
  TextEditingController _messageController = TextEditingController();
  final _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser!.email;

    var email = ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<QuerySnapshot>(
      stream: massages.orderBy("time", descending: true).snapshots(),
      builder: (context, snapshot) {
        List<Message> messagesList = [];
        if (snapshot.hasData) {
          for (var element in snapshot.data!.docs) {
            messagesList.add(Message.fromJson(element.data() as Map));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.hasClients) {
              _controller.animateTo(
                0,
                // _controller.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          });

          return Scaffold(
            appBar: AppBar(title: Text('Chat')),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: _controller,
                    itemCount: messagesList.length,
                    itemBuilder:
                        (context, index) =>
                            // sendtmoazChatBubble(message: messagesList[index]),
                            // restmoazChatBubble(message: messagesList[index]),
                            // senderBubble(message: messagesList[index]),
                            // receiverBubble(message: messagesList[index])
                            // messagesList[index].email == currentUser
                            //     ? sendtmoazChatBubble(
                            //       message: messagesList[index],
                            //     )
                            //     : restmoazChatBubble(
                            //       message: messagesList[index],
                            //     ),
                            messagesList[index].email == currentUser
                                ? senderBubble(message: messagesList[index])
                                : receiverBubble(message: messagesList[index]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,

                          onSubmitted: (value) {
                            massages.add({
                              'messages': value,
                              'isSentByMe': true,
                              // 'isSentByMe': true,
                              'time': DateTime.now(),
                              'email': currentUser,
                            });
                            // setState(() {});
                            _messageController.clear();
                          },
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.send)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text('Loading...');
        }
      },
    );
  }
}
