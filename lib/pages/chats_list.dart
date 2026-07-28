import 'package:authentication_app/models/chat_model.dart';
import 'package:authentication_app/models/user_model.dart';
import 'package:authentication_app/pages/users_list.dart';
import 'package:authentication_app/services/chat_service.dart';
import 'package:authentication_app/constants/ai_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _getAiChatId(String currentUid) {
    final sorted = [currentUid, AiConstants.aiUserId]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () async {
              await _chatService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in your chats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Chats list
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: _chatService.getMyChats(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data ?? [];
                final aiChats =
                    chats
                        .where(
                          (chat) =>
                              chat.participants.contains(AiConstants.aiUserId),
                        )
                        .toList();
                final ChatModel? aiChat = aiChats.isNotEmpty ? aiChats.first : null;
                final privateChats =
                    chats
                        .where(
                          (chat) =>
                              !chat.participants.contains(AiConstants.aiUserId),
                        )
                        .toList();

                return ListView.separated(
                  itemCount: privateChats.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final aiSubtitle =
                          aiChat == null || aiChat.lastMessage.isEmpty
                              ? AiConstants.aiDefaultMessage
                              : aiChat.lastMessage;
                      final aiUnreadCount =
                          aiChat?.getUnreadCountForUser(currentUser.uid) ?? 0;

                      if (_searchQuery.isNotEmpty) {
                        final matchesAi = AiConstants.aiDisplayName
                            .toLowerCase()
                            .contains(
                              _searchQuery,
                            ) ||
                            AiConstants.aiEmail.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            aiSubtitle.toLowerCase().contains(_searchQuery);
                        if (!matchesAi) {
                          return const SizedBox.shrink();
                        }
                      }

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1A73E8),
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                        title: const Text(AiConstants.aiDisplayName),
                        subtitle: Text(
                          aiSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing:
                            aiUnreadCount > 0
                                ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    aiUnreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : null,
                        onTap: () async {
                          final chatId =
                              aiChat?.id ?? _getAiChatId(currentUser.uid);
                          if (aiChat == null) {
                            await _chatService.createOrGetChat(
                              currentUid: currentUser.uid,
                              otherUid: AiConstants.aiUserId,
                              currentEmail:
                                  currentUser.email ?? 'unknown@chat.app',
                              otherEmail: AiConstants.aiEmail,
                            );
                          }

                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'chatId': chatId,
                                'receiverId': AiConstants.aiUserId,
                                'receiverName': AiConstants.aiDisplayName,
                              },
                            );
                          }
                        },
                      );
                    }

                    final chat = privateChats[index - 1];
                    final otherUserId = chat.getOtherParticipantId(
                      currentUser.uid,
                    );
                    final unreadCount = chat.getUnreadCountForUser(
                      currentUser.uid,
                    );

                    return FutureBuilder<UserModel?>(
                      future: _chatService.getUserById(otherUserId),
                      builder: (context, userSnapshot) {
                        final otherUser = userSnapshot.data;
                        final displayName =
                            otherUser?.displayName ?? otherUserId;
                        final email = otherUser?.email ?? '';

                        // Filter by search query
                        if (_searchQuery.isNotEmpty) {
                          final matchesName = displayName
                              .toLowerCase()
                              .contains(_searchQuery);
                          final matchesEmail = email.toLowerCase().contains(
                            _searchQuery,
                          );
                          final matchesMessage = chat.lastMessage
                              .toLowerCase()
                              .contains(_searchQuery);
                          if (!matchesName &&
                              !matchesEmail &&
                              !matchesMessage) {
                            return const SizedBox.shrink();
                          }
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(
                            displayName.isEmpty ? email : displayName,
                          ),
                          subtitle: Text(
                            chat.lastMessage.isEmpty
                                ? 'Start chatting...'
                                : chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing:
                              unreadCount > 0
                                  ? CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                  : null,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'chatId': chat.id,
                                'receiverId': otherUserId,
                                'receiverName': displayName,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsersListPage()),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
