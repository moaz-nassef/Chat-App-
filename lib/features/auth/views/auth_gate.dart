import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../chats/views/chats_list_view.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'welcome_view.dart';

/// The app entry widget: decides what to show based on the auth session.
/// Signed in → chats list. Signed out → welcome/onboarding.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen:
          (previous, current) =>
              current is AuthAuthenticated ||
              current is AuthUnauthenticated ||
              current is AuthInitial,
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const ChatsListView();
        }
        if (state is AuthUnauthenticated) {
          return const WelcomeView();
        }
        // AuthInitial / AuthLoading → branded splash.
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}
