import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Unified SnackBars for the whole app — success (green) / error (red).
abstract class AppSnackBar {
  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
