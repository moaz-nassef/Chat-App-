import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../../auth/data/user_model.dart';
import '../data/chat_model.dart';
import 'unread_badge.dart';

/// A single chat row in the chats list.
class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.unreadCount,
    required this.onTap,
    this.onLongPress,
  });

  final ChatModel chat;

  /// Resolved from the users directory (null → show fallback).
  final UserModel? otherUser;
  final int unreadCount;
  final VoidCallback onTap;

  /// Long-press → delete chat.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final displayName =
        (otherUser?.displayName.isNotEmpty ?? false)
            ? otherUser!.displayName
            : (otherUser?.email ?? 'مستخدم');

    return ListTile(
      leading: UserAvatar(
        initial: otherUser?.initial ?? '?',
        photoUrl: otherUser?.photoUrl,
        online: otherUser?.online ?? false,
        showOnlineDot: true,
      ),
      title: Text(displayName),
      subtitle: Text(
        chat.lastMessage.isEmpty ? 'Start chatting...' : chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormatter.chatListTime(chat.lastMessageTime),
            style: TextStyle(
              fontSize: 11,
              color: unreadCount > 0 ? AppColors.success : Colors.grey[600],
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          UnreadBadge(count: unreadCount),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
