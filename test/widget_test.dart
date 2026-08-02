import 'package:chat_app/core/utils/date_formatter.dart';
import 'package:chat_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email accepts a valid address', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('email rejects empty / invalid values', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('password requires at least 6 chars', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword must match the original', () {
      final confirm = Validators.confirmPassword('secret1');
      expect(confirm('secret1'), isNull);
      expect(confirm('other'), isNotNull);
    });

    test('displayName requires at least 3 chars', () {
      expect(Validators.displayName('ab'), isNotNull);
      expect(Validators.displayName('Moaz'), isNull);
    });
  });

  group('DateFormatter', () {
    test('time formats HH:mm with padding', () {
      expect(DateFormatter.time(DateTime(2026, 7, 28, 9, 5)), '09:05');
    });

    test('chatListTime shows time for today', () {
      final now = DateTime.now();
      final result = DateFormatter.chatListTime(now);
      expect(result, DateFormatter.time(now));
    });

    test('chatListTime shows Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.chatListTime(yesterday), 'Yesterday');
    });
  });
}
