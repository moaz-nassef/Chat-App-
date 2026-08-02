import 'package:flutter/material.dart';

import '../../../../core/constants/ai_constants.dart';
import '../../../../core/constants/app_colors.dart';
import 'unread_badge.dart';

/// The pinned AI-assistant row at the top of the chats list.
class AiChatTile extends StatelessWidget {
  const AiChatTile({
    super.key,
    required this.subtitle,
    required this.unreadCount,
    required this.onTap,
  });

  final String subtitle;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.aiBlue,
        child: Icon(Icons.smart_toy, color: Colors.white),
      ),
      title: const Row(
        children: [
          Text(AiConstants.aiDisplayName),
          SizedBox(width: 6),
          Icon(Icons.verified, size: 16, color: AppColors.aiBlue),
        ],
      ),
      subtitle: Text(
        subtitle.isEmpty ? AiConstants.aiDefaultMessage : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: UnreadBadge(count: unreadCount),
      onTap: onTap,
    );
  }
}
