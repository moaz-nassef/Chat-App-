import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _showResetPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('إعادة تعيين كلمة المرور'),
            content: TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final email = resetController.text.trim();
                  if (Validators.email(email) != null) return;
                  context.read<AuthCubit>().sendPasswordResetEmail(email);
                  Navigator.pop(dialogContext);
                },
                child: const Text('إرسال'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen:
          (previous, current) =>
              current is AuthAuthenticated ||
              current is AuthError ||
              current is AuthPasswordResetSent,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AppSnackBar.success(context, '✔ تم تسجيل الدخول بنجاح! 🎉');
          // AuthGate (the home route) swaps to the chats screen.
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is AuthError) {
          AppSnackBar.error(context, state.message);
        } else if (state is AuthPasswordResetSent) {
          AppSnackBar.success(
            context,
            '✔ تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
          );
        }
      },
      child: AuthScaffold(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Login Page',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primaryMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/login.svg',
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _emailController,
                    hintTextAr: 'البريد الإلكتروني',
                    hintTextEn: 'Your Email',
                    icon: Icons.person,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: _passwordController,
                    hintTextAr: 'كلمة المرور',
                    hintTextEn: 'Password',
                    icon: Icons.lock,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primary,
                      ),
                      onPressed:
                          () => setState(() => _obscureText = !_obscureText),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showResetPasswordDialog,
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen:
                        (previous, current) =>
                            (previous is AuthLoading) !=
                            (current is AuthLoading),
                    builder: (context, state) {
                      return AuthButton(
                        label: 'تسجيل الدخول - LOGIN',
                        isLoading: state is AuthLoading,
                        onPressed: _handleLogin,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      TextButton(
                        onPressed:
                            () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
