import 'package:authentication_app/models/user_model.dart';
import 'package:authentication_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      appBar: AppBar(title: const Text('All Users')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
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
          // Users list
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _chatService.getAllUsersExcept(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No users found yet.'));
                }

                // Filter users by search query
                final filteredUsers =
                    _searchQuery.isEmpty
                        ? users
                        : users.where((user) {
                          final matchesName = user.displayName
                              .toLowerCase()
                              .contains(_searchQuery);
                          final matchesEmail = user.email
                              .toLowerCase()
                              .contains(_searchQuery);
                          return matchesName || matchesEmail;
                        }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users match your search.'),
                  );
                }

                return ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.displayName.isEmpty
                              ? '?'
                              : user.displayName[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        user.displayName.isEmpty
                            ? user.email
                            : user.displayName,
                      ),
                      subtitle: Text(user.email),
                      trailing:
                          user.online
                              ? const Icon(
                                Icons.circle,
                                color: Colors.green,
                                size: 12,
                              )
                              : null,
                      onTap: () async {
                        final chatId = await _chatService.createOrGetChat(
                          currentUid: currentUser.uid,
                          otherUid: user.uid,
                          currentEmail: currentUser.email ?? '',
                          otherEmail: user.email,
                        );
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              'chatId': chatId,
                              'receiverId': user.uid,
                              'receiverName': user.displayName,
                            },
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
