import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';

/// Controls for an established audio call.
class InCallView extends StatefulWidget {
  const InCallView({super.key, required this.args});

  final CallRouteArgs args;

  @override
  State<InCallView> createState() => _InCallViewState();
}

class _InCallViewState extends State<InCallView> {
  Timer? _timer;
  var _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallIdle) Navigator.pop(context);
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => context.read<CallCubit>().endCall(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                CircleAvatar(
                  radius: 68,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.args.peerPhotoUrl?.isNotEmpty == true
                      ? NetworkImage(widget.args.peerPhotoUrl!)
                      : null,
                  child: widget.args.peerPhotoUrl?.isNotEmpty == true
                      ? null
                      : Text(
                          widget.args.peerName.isEmpty
                              ? '?'
                              : widget.args.peerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 48),
                        ),
                ),
                const SizedBox(height: 24),
                Text(widget.args.peerName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(_durationText, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(flex: 3),
                BlocBuilder<CallCubit, CallState>(
                  builder: (context, state) {
                    final muted = state is CallConnected && state.isMuted;
                    final speaker = state is CallConnected && state.isSpeakerOn;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _control(
                          context,
                          icon: muted ? Icons.mic_off : Icons.mic,
                          label: muted ? 'تشغيل الميكروفون' : 'كتم',
                          active: muted,
                          onTap: () => context.read<CallCubit>().toggleMute(),
                        ),
                        _control(
                          context,
                          icon: speaker ? Icons.volume_up : Icons.volume_down,
                          label: 'السماعة',
                          active: speaker,
                          onTap: () => context.read<CallCubit>().toggleSpeaker(),
                        ),
                        _control(
                          context,
                          icon: Icons.call_end_rounded,
                          label: 'إنهاء',
                          active: true,
                          activeColor: AppColors.error,
                          onTap: () => context.read<CallCubit>().endCall(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 52),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _durationText {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _control(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    Color? activeColor,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: active
              ? activeColor ?? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.all(18),
        ),
        child: Icon(icon, size: 26),
      ),
      const SizedBox(height: 8),
      Text(label),
    ],
  );
}
