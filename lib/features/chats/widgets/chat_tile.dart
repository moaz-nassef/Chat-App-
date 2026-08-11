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
    final hasUnread = unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AppColors.primaryLight.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(
                  initial: otherUser?.initial ?? '?',
                  photoUrl: otherUser?.photoUrl,
                  online: otherUser?.online ?? false,
                  showOnlineDot: true,
                  radius: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        chat.lastMessage.isEmpty
                            ? 'Start chatting...'
                            : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.chatListTime(chat.lastMessageTime),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasUnread
                            ? AppColors.primaryMedium
                            : AppColors.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    UnreadBadge(count: unreadCount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
