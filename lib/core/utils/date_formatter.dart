/// Date/time formatting helpers shared across chat widgets.
abstract class DateFormatter {
  /// '14:05'
  static String time(DateTime? date) {
    if (date == null) return '--:--';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Timestamp shown in the chats list:
  /// today → '14:05', yesterday → 'Yesterday', otherwise → '28/07/2026'
  static String chatListTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) return time(date);
    if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// 'Last seen 14:05' / 'Last seen Yesterday' / 'Last seen 28/07/2026'
  static String lastSeen(DateTime? date) {
    if (date == null) return 'offline';
    return 'Last seen ${chatListTime(date)}';
  }
}
