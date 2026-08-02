/// Reusable form validators (used by login/signup views).
abstract class Validators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'من فضلك أدخل البريد الإلكتروني';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'البريد الإلكتروني غير صحيح';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'من فضلك أدخل كلمة المرور';
    if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  static String? displayName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'من فضلك أدخل الاسم';
    if (v.length < 3) return 'الاسم قصير جداً';
    return null;
  }

  /// Confirm-password validator; pass the original password value.
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      final v = value ?? '';
      if (v.isEmpty) return 'من فضلك أكد كلمة المرور';
      if (v != original) return 'كلمة المرور غير متطابقة';
      return null;
    };
  }
}
