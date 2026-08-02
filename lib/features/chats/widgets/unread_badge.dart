import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

/// Green unread-count badge used on chat tiles.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.success,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
