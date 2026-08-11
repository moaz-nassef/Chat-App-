import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di_container.dart';
import 'core/router/app_router.dart';
import 'core/services/presence_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/views/auth_gate.dart';
import 'features/calls/cubit/call_cubit.dart';
import 'features/calls/cubit/call_state.dart';

/// Root widget: DI-provided singletons + theme + routing + presence.
class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String? _presentedIncomingCallId;
  @override
  void initState() {
    super.initState();
    // Online/offline status follows the app lifecycle.
    sl<PresenceService>().start();
  }

  @override
  void dispose() {
    sl<PresenceService>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<CallCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.read<CallCubit>().watchIncomingCalls(state.user.uid);
              } else if (state is AuthUnauthenticated) {
                context.read<CallCubit>().stopIncomingCalls();
              }
            },
          ),
          BlocListener<CallCubit, CallState>(
            listener: (context, state) {
              if (state is CallIdle) _presentedIncomingCallId = null;
              if (state is CallIncoming &&
                  _presentedIncomingCallId != state.call.id) {
                _presentedIncomingCallId = state.call.id;
                _navigatorKey.currentState?.pushNamed(
                  AppRoutes.incomingCall,
                  arguments: CallRouteArgs(
                    call: state.call,
                    peerName: state.call.callerName,
                    peerPhotoUrl: state.call.callerPhotoUrl,
                  ),
                );
              }
            },
          ),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Chat App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
