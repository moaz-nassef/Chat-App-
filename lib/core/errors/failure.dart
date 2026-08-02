import 'package:firebase_auth/firebase_auth.dart';

/// Unified error type thrown by every repository.
/// Cubits catch [Failure] and emit an error state with [message].
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication errors (FirebaseAuth).
class AuthFailure extends Failure {
  const AuthFailure(super.message);

  /// Maps FirebaseAuth error codes to user-friendly messages.
  factory AuthFailure.fromException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure('❌ هذا الإيميل غير مسجل');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('❌ الإيميل أو كلمة المرور غير صحيحة');
      case 'invalid-email':
        return const AuthFailure('❌ صيغة الإيميل غير صالحة');
      case 'user-disabled':
        return const AuthFailure('❌ هذا الحساب تم تعطيله');
      case 'weak-password':
        return const AuthFailure('❌ كلمة المرور ضعيفة جداً');
      case 'email-already-in-use':
        return const AuthFailure('❌ يوجد حساب مسجل بهذا الإيميل بالفعل');
      case 'too-many-requests':
        return const AuthFailure('❌ محاولات كثيرة، حاول لاحقاً');
      case 'network-request-failed':
        return const AuthFailure('❌ تحقق من اتصالك بالإنترنت');
      default:
        return AuthFailure('❌ خطأ غير متوقع: ${e.message ?? e.code}');
    }
  }
}

/// Firestore read/write errors.
class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message);

  factory FirestoreFailure.fromException(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return const FirestoreFailure('❌ ليس لديك صلاحية لهذه العملية');
    }
    if (e.code == 'unavailable') {
      return const FirestoreFailure('❌ الخدمة غير متاحة، تحقق من الإنترنت');
    }
    return FirestoreFailure('❌ خطأ في قاعدة البيانات: ${e.message ?? e.code}');
  }
}

/// AI assistant errors.
class AiFailure extends Failure {
  const AiFailure(super.message);
}

/// Anything else.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '❌ حدث خطأ غير متوقع']);

  factory UnknownFailure.fromException(Object e) => UnknownFailure('❌ $e');
}
