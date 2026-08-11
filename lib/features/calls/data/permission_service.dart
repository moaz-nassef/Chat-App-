import 'package:permission_handler/permission_handler.dart';

import '../../../core/errors/failure.dart';

/// Requests microphone permission immediately before an audio call starts.
class PermissionService {
  /// Requests microphone access.
  ///
  /// Throws [UnknownFailure] with a human-readable message when the user
  /// denies the request. When the permission is permanently denied (the
  /// system no longer shows a prompt), the app settings screen is opened so
  /// the user can enable it manually.
  Future<void> ensureMicrophoneAccess() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      throw const UnknownFailure(
        'تم منع إذن الميكروفون نهائيًا. افتح إعدادات التطبيق وفعّل الميكروفون ثم أعد المحاولة.',
      );
    }

    throw const UnknownFailure('يلزم السماح بالوصول إلى الميكروفون لإجراء مكالمة.');
  }
}
