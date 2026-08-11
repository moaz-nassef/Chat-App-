import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';
import 'calling_view.dart';

/// Shown when an audio-call signalling document targets the signed-in user.
class IncomingCallView extends StatelessWidget {
  const IncomingCallView({super.key, required this.args});

  final CallRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallIdle) Navigator.pop(context);
        if (state is CallFailure) {
          AppSnackBar.error(context, state.message);
          Navigator.pop(context);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => context.read<CallCubit>().declineCall(),
        child: CallScaffold(
          name: args.peerName,
          photoUrl: args.peerPhotoUrl,
          status: 'مكالمة صوتية واردة',
          actions: [
            CallRoundAction(
              icon: Icons.call_end_rounded,
              label: 'رفض',
              color: AppColors.error,
              onPressed: () => context.read<CallCubit>().declineCall(),
            ),
            CallRoundAction(
              icon: Icons.call_rounded,
              label: 'قبول',
              color: AppColors.success,
              onPressed: () async {
                final accepted = await context.read<CallCubit>().acceptCall();
                if (accepted && context.mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.inCall,
                    arguments: args,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
