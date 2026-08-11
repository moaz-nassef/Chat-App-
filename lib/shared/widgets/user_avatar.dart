import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Circle avatar with the user's initial (or photo) + optional online dot.
///
/// When no photo is available, a deterministic gradient is derived from the
/// initial so the same contact always keeps the same colour across screens.
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

  /// Six gradients cycled by the first letter of [initial] (A→0, B→1, …).
  static const List<List<Color>> _palettes = [
    [Color(0xFF7B1FA2), Color(0xFFCE93D8)], // purple
    [Color(0xFF1565C0), Color(0xFF90CAF9)], // blue
    [Color(0xFF00838F), Color(0xFF80DEEA)], // teal
    [Color(0xFFE65100), Color(0xFFFFCC80)], // orange
    [Color(0xFF2E7D32), Color(0xFFA5D6A7)], // green
    [Color(0xFFAD1457), Color(0xFFF48FB1)], // pink
  ];

  List<Color> _paletteFor(String letter) {
    if (letter.isEmpty) return _palettes.first;
    final code = letter.codeUnitAt(0);
    return _palettes[code % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    final Widget avatar;
    if (hasPhoto) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: NetworkImage(photoUrl!),
      );
    } else {
      final palette =
          backgroundColor == null
              ? _paletteFor(initial)
              : [backgroundColor!, backgroundColor!];
      avatar = CircleAvatar(
        radius: radius,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial.isEmpty ? '?' : initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (!showOnlineDot) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.6,
            height: radius * 0.6,
            decoration: BoxDecoration(
              color: online ? AppColors.online : const Color(0xFFBDBDBD),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (online ? AppColors.online : const Color(0xFFBDBDBD))
                      .withValues(alpha: 0.35),
                  blurRadius: 3,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
