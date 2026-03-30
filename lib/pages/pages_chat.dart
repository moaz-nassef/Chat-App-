import 'package:authentication_app/models/message_model.dart';
import 'package:authentication_app/pages/Widget__chat_bubble.dart';
import 'package:authentication_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final chatId = args?['chatId']?.toString() ?? '';
    final receiverId = args?['receiverId']?.toString() ?? '';
    final receiverName = args?['receiverName']?.toString() ?? '';

    if (chatId.isEmpty || receiverId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Missing conversation information.')),
      );
    }

    // Mark all messages as read when opening chat
    _chatService.markAllMessagesAsRead(
      chatId: chatId,
      currentUid: currentUser.uid,
    );

    return StreamBuilder<List<MessageModel>>(
      stream: _chatService.getMessages(chatId),
      builder: (context, snapshot) {
        List<MessageModel> messagesList = [];
        if (snapshot.hasData) {
          messagesList = snapshot.data!.toList().reversed.toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_controller.hasClients) {
              _controller.animateTo(
                _controller.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: Text(receiverName.isEmpty ? 'Private Chat' : receiverName),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      final message = messagesList[index];
                      final isSender = message.senderId == currentUser.uid;
                      return isSender
                          ? senderBubble(message: message)
                          : receiverBubble(message: message);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _chatService.sendMessage(
                                chatId: chatId,
                                senderId: currentUser.uid,
                                text: value.trim(),
                              );
                              _messageController.clear();
                            }
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
                      IconButton(
                        onPressed: () {
                          final text = _messageController.text.trim();
                          if (text.isNotEmpty) {
                            _chatService.sendMessage(
                              chatId: chatId,
                              senderId: currentUser.uid,
                              text: text,
                            );
                            _messageController.clear();
                          }
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(body: Center(child: Text('Loading...')));
        }
      },
    );
  }
}
