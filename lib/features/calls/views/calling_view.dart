import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';

/// Full-screen state while the caller waits for the receiver to answer.
class CallingView extends StatelessWidget {
  const CallingView({super.key, required this.args});

  final CallRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallConnected) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.inCall,
            arguments: args,
          );
        } else if (state is CallFailure) {
          AppSnackBar.error(context, state.message);
          Navigator.pop(context);
        } else if (state is CallIdle) {
          Navigator.pop(context);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => context.read<CallCubit>().endCall(),
        child: CallScaffold(
          name: args.peerName,
          photoUrl: args.peerPhotoUrl,
          status: 'جاري الاتصال…',
          actions: [
            CallRoundAction(
              icon: Icons.call_end_rounded,
              label: 'إنهاء',
              color: AppColors.error,
              onPressed: () => context.read<CallCubit>().endCall(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared visual shell for the three audio call screens.
class CallScaffold extends StatelessWidget {
  const CallScaffold({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.status,
    required this.actions,
  });

  final String name;
  final String? photoUrl;
  final String status;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark
            ? const [Color(0xFF171127), Color(0xFF25153E), Color(0xFF102545)]
            : const [Color(0xFFF8F1FB), Color(0xFFE8D9F6), Color(0xFFDDEBFA)];
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              CircleAvatar(
                radius: 72,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    photoUrl?.isNotEmpty == true
                        ? NetworkImage(photoUrl!)
                        : null,
                child:
                    photoUrl?.isNotEmpty == true
                        ? null
                        : Text(
                          name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 28),
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(
                status,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
              const SizedBox(height: 54),
            ],
          ),
        ),
      ),
    );
  }
}

class CallRoundAction extends StatelessWidget {
  const CallRoundAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
