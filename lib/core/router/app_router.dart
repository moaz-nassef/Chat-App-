import 'package:flutter/material.dart';

import '../../features/ai_chat/views/ai_settings_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/signup_view.dart';
import '../../features/auth/views/start_view.dart';
import '../../features/auth/views/welcome_view.dart';
import '../../features/chat_detail/views/chat_view.dart';
import '../../features/chats/views/chats_list_view.dart';
import '../../features/calls/data/call_model.dart';
import '../../features/calls/views/calling_view.dart';
import '../../features/calls/views/in_call_view.dart';
import '../../features/calls/views/incoming_call_view.dart';
import '../../features/users/views/users_list_view.dart';

/// Central route names — no magic strings in the views.
abstract class AppRoutes {
  static const String welcome = '/welcome';
  static const String start = '/start';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String chats = '/chats';
  static const String users = '/users';
  static const String chat = '/chat';
  static const String aiSettings = '/ai-settings';
  static const String calling = '/calling';
  static const String incomingCall = '/incoming-call';
  static const String inCall = '/in-call';
}

/// Strongly-typed arguments for [AppRoutes.chat]
/// (replaces the old `Map` from ModalRoute.settings.arguments).
class ChatViewArgs {
  const ChatViewArgs({
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  final String chatId;
  final String receiverId;
  final String receiverName;
}

/// Arguments shared by all call screens.
class CallRouteArgs {
  const CallRouteArgs({
    required this.call,
    required this.peerName,
    this.peerPhotoUrl,
  });

  final CallModel call;
  final String peerName;
  final String? peerPhotoUrl;
}

/// onGenerateRoute — one place for all navigation wiring.
abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _page(const WelcomeView());
      case AppRoutes.start:
        return _page(const StartView());
      case AppRoutes.login:
        return _page(const LoginView());
      case AppRoutes.signup:
        return _page(const SignupView());
      case AppRoutes.chats:
        return _page(const ChatsListView());
      case AppRoutes.users:
        return _page(const UsersListView());
      case AppRoutes.chat:
        final args = settings.arguments;
        if (args is! ChatViewArgs) {
          return _page(const _RouteError(message: 'Missing chat arguments'));
        }
        return _page(ChatView(args: args));
      case AppRoutes.aiSettings:
        return _page(const AiSettingsView());
      case AppRoutes.calling:
        final args = settings.arguments;
        return args is CallRouteArgs
            ? _page(CallingView(args: args))
            : _page(const _RouteError(message: 'Missing call arguments'));
      case AppRoutes.incomingCall:
        final args = settings.arguments;
        return args is CallRouteArgs
            ? _page(IncomingCallView(args: args))
            : _page(const _RouteError(message: 'Missing call arguments'));
      case AppRoutes.inCall:
        final args = settings.arguments;
        return args is CallRouteArgs
            ? _page(InCallView(args: args))
            : _page(const _RouteError(message: 'Missing call arguments'));
      default:
        return _page(const _RouteError(message: 'Unknown route'));
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}

class _RouteError extends StatelessWidget {
  const _RouteError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
