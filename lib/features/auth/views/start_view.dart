import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/auth_scaffold.dart';

/// Second screen — choose login or signup.
class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBottomDecoration: false,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryDark,
                size: 30,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/images/main_bottom.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'مرحباً بك',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primaryMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset('assets/icons/chat.svg', height: 280),
                ),
                const SizedBox(height: 40),
                _StartButton(
                  textAr: 'تسجيل الدخول',
                  textEn: 'LOGIN',
                  isPrimary: true,
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.login),
                ),
                const SizedBox(height: 20),
                _StartButton(
                  textAr: 'إنشاء حساب',
                  textEn: 'SIGNUP',
                  isPrimary: false,
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.signup),
                ),
                const Spacer(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.textAr,
    required this.textEn,
    required this.isPrimary,
    required this.onPressed,
  });

  final String textAr;
  final String textEn;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder:
          (context, value, child) =>
              Transform.scale(scale: value, child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color:
                  isPrimary
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? AppColors.primary : Colors.white,
            foregroundColor: isPrimary ? Colors.white : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isPrimary ? Colors.transparent : AppColors.primary,
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                textAr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                textEn,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
