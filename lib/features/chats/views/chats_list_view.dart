import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/ai_constants.dart';
import '../../../core/di_container.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_text_field.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/data/user_model.dart';
import '../cubit/chats_cubit.dart';
import '../cubit/chats_state.dart';
import '../widgets/ai_chat_tile.dart';
import '../widgets/chat_tile.dart';

/// Home screen after login: pinned AI chat + my conversations.
class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      // AuthGate guarantees we never get here — defensive fallback.
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return BlocProvider(
      create: (_) => sl<ChatsCubit>()..watchChats(authState.user.uid),
      child: _ChatsListBody(currentUser: authState.user),
    );
  }
}

class _ChatsListBody extends StatefulWidget {
  const _ChatsListBody({required this.currentUser});

  final UserModel currentUser;

  @override
  State<_ChatsListBody> createState() => _ChatsListBodyState();
}

class _ChatsListBodyState extends State<_ChatsListBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('خروج'),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      // AuthGate swaps to WelcomeView when the auth stream fires.
      await context.read<AuthCubit>().signOut();
    }
  }

  Future<void> _confirmDeleteChat(String chatId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('حذف المحادثة'),
            content: const Text('سيتم حذف المحادثة وكل رسائلها نهائياً.'),
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
      await context.read<ChatsCubit>().deleteChat(chatId);
    }
  }

  Future<void> _openAiChat() async {
    final user = widget.currentUser;
    try {
      final chatId = await context.read<ChatsCubit>().createOrGetChat(
        currentUid: user.uid,
        otherUid: AiConstants.aiUserId,
        currentEmail: user.email.isEmpty ? 'unknown@chat.app' : user.email,
        otherEmail: AiConstants.aiEmail,
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ChatViewArgs(
          chatId: chatId,
          receiverId: AiConstants.aiUserId,
          receiverName: AiConstants.aiDisplayName,
        ),
      );
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = widget.currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Column(
        children: [
          SearchTextField(
            controller: _searchController,
            hintText: 'Search in your chats...',
            onChanged:
                (value) => context.read<ChatsCubit>().setSearchQuery(value),
          ),
          Expanded(
            child: BlocConsumer<ChatsCubit, ChatsState>(
              listenWhen:
                  (previous, current) =>
                      current is ChatsError && previous is! ChatsError,
              listener: (context, state) {
                if (state is ChatsError) {
                  AppSnackBar.error(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is ChatsLoading || state is ChatsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatsError) {
                  return EmptyState(
                    icon: Icons.cloud_off,
                    title: 'تعذر تحميل المحادثات',
                    subtitle: state.message,
                  );
                }

                final loaded = state as ChatsLoaded;
                final visibleChats = loaded.visibleChats(
                  myUid,
                  AiConstants.aiUserId,
                );
                final aiChat = loaded.aiChat(AiConstants.aiUserId);

                if (visibleChats.isEmpty && !loaded.aiVisible) {
                  return const EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'لا توجد محادثات بعد',
                    subtitle: 'اضغط على زر + لبدء محادثة جديدة',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: visibleChats.length + (loaded.aiVisible ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Pinned AI tile first.
                    if (loaded.aiVisible && index == 0) {
                      return AiChatTile(
                        subtitle: aiChat?.lastMessage ?? '',
                        unreadCount: aiChat?.unreadFor(myUid) ?? 0,
                        onTap: _openAiChat,
                      );
                    }

                    final chatIndex = loaded.aiVisible ? index - 1 : index;
                    final chat = visibleChats[chatIndex];
                    final otherId = chat.otherParticipantId(myUid);
                    final otherUser = loaded.usersById[otherId];

                    return ChatTile(
                      chat: chat,
                      otherUser: otherUser,
                      unreadCount: chat.unreadFor(myUid),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chat,
                          arguments: ChatViewArgs(
                            chatId: chat.id,
                            receiverId: otherId,
                            receiverName: otherUser?.displayName ?? otherId,
                          ),
                        );
                      },
                      onLongPress: () => _confirmDeleteChat(chat.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.users),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New Chat'),
      ),
    );
  }
}
