import 'package:flutter/material.dart';

/// Central color palette for the whole app.
/// Extracted from the original design (purple/blue gradient identity).
abstract class AppColors {
  // Primary (purple)
  static const Color primary = Color(0xFF9C27B0);
  static const Color primaryDark = Color(0xFF6A1B9A);
  static const Color primaryMedium = Color(0xFF8E24AA);
  static const Color primaryLight = Color(0xFF7B1FA2);

  // Accent (blue)
  static const Color accent = Color(0xFF1976D2);
  static const Color accentDark = Color(0xFF1565C0);
  static const Color aiBlue = Color(0xFF1A73E8);

  // Gradients
  static const List<Color> purpleGradient = [
    Color(0xFFF3E5F5),
    Color(0xFFE1BEE7),
    Color(0xFFCE93D8),
  ];
  static const List<Color> blueGradient = [
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
    Color(0xFF90CAF9),
  ];

  // Chat bubbles
  static const Color senderBubble = Color(0xFFF3B2FF);
  static const Color receiverBubble = Colors.white;
  static const Color aiBubble = Color(0xFFE8F0FE);

  // States
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color online = Colors.green;

  // Neutral
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color fieldFill = Color(0xFFEEEEEE);
}
