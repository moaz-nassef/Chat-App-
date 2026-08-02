import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Circle avatar with the user's initial (or photo) + optional online dot.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initial,
    this.photoUrl,
    this.online = false,
    this.showOnlineDot = false,
    this.radius = 24,
    this.backgroundColor,
  });

  final String initial;
  final String? photoUrl;
  final bool online;
  final bool showOnlineDot;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      backgroundImage:
          (photoUrl != null && photoUrl!.isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
      child:
          (photoUrl == null || photoUrl!.isEmpty)
              ? Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              )
              : null,
    );

    if (!showOnlineDot) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.55,
            height: radius * 0.55,
            decoration: BoxDecoration(
              color: online ? AppColors.online : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
