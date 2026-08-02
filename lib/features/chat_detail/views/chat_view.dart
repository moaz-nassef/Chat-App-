import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/ai_constants.dart';
import '../../../core/di_container.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/chat_bubble.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../users/data/users_repo.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../data/message_model.dart';
import '../widgets/ai_typing_indicator.dart';
import '../widgets/message_input_field.dart';

/// One open conversation (1:1 or with the AI assistant).
class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.args});

  final ChatViewArgs args;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return BlocProvider(
      create:
          (_) =>
              sl<MessagesCubit>()..openChat(
                chatId: args.chatId,
                myUid: authState.user.uid,
                receiverId: args.receiverId,
              ),
      child: _ChatBody(args: args, myUid: authState.user.uid),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody({required this.args, required this.myUid});

  final ChatViewArgs args;
  final String myUid;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  bool get _isAiChat => widget.args.receiverId == AiConstants.aiUserId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    context.read<MessagesCubit>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // reverse: true → bottom is offset 0
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmDeleteMessage(MessageModel message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('حذف الرسالة'),
            content: const Text('هل تريد حذف هذه الرسالة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      await context.read<MessagesCubit>().deleteMessage(message.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(
        title: _isAiChat ? _buildAiTitle() : _buildUserTitle(),
        actions: [
          if (_isAiChat)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'إعدادات الذكاء الاصطناعي',
              onPressed:
                  () => Navigator.pushNamed(context, AppRoutes.aiSettings),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<MessagesCubit, MessagesState>(
              listenWhen: (previous, current) {
                return current is MessagesLoaded &&
                    current.actionError != null &&
                    previous != current;
              },
              listener: (context, state) {
                if (state is MessagesLoaded && state.actionError != null) {
                  AppSnackBar.error(context, state.actionError!);
                  context.read<MessagesCubit>().clearActionError();
                }
              },
              builder: (context, state) {
                if (state is MessagesLoading || state is MessagesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesError) {
                  return Center(child: Text(state.message));
                }

                final loaded = state as MessagesLoaded;
                final messages = loaded.messages; // newest first

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // index 0 = latest, pinned to the bottom
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length + (loaded.isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (loaded.isAiTyping && index == 0) {
                      return const AiTypingIndicator();
                    }

                    final messageIndex = loaded.isAiTyping ? index - 1 : index;
                    final message = messages[messageIndex];
                    final isMine =
                        message.senderId == widget.myUid && !message.isAi;

                    return ChatBubble(
                      message: message,
                      isMine: isMine,
                      onLongPress:
                          isMine ? () => _confirmDeleteMessage(message) : null,
                    );
                  },
                );
              },
            ),
          ),
          MessageInputField(controller: _messageController, onSend: _send),
        ],
      ),
    );
  }

  /// AI chat → static title.
  Widget _buildAiTitle() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF1A73E8),
          child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AiConstants.aiDisplayName, style: TextStyle(fontSize: 16)),
            Text(
              'Always online',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  /// 1:1 chat → live online/last-seen from the users directory.
  Widget _buildUserTitle() {
    return StreamBuilder(
      stream: sl<UsersRepo>().watchUser(widget.args.receiverId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name =
            (user?.displayName.isNotEmpty ?? false)
                ? user!.displayName
                : widget.args.receiverName;
        final status =
            user == null
                ? ''
                : user.online
                ? 'Online'
                : DateFormatter.lastSeen(user.lastSeen);

        return Row(
          children: [
            UserAvatar(
              initial: user?.initial ?? '?',
              photoUrl: user?.photoUrl,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status.isNotEmpty)
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            (user?.online ?? false)
                                ? Colors.green
                                : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
